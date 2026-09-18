#include "futex.h"

#include <assert.h>
#include <errno.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static volatile int word = 0;

static void *waiter_thread(void *arg)
{
    (void)arg;
    int rc = qnx_futex(&word, FUTEX_WAIT, 0, NULL, NULL, 0);
    if (rc != 0)
        fprintf(stderr, "waiter: rc=%d errno=%d word=%d\n", rc, errno, word);
    assert(rc == 0);
    assert(word == 99);
    return NULL;
}

/* waiters that never get woken, used to test requeue */
static pthread_t parked[4];
static int parked_started = 0;

static void *parked_thread(void *arg)
{
    volatile int *addr = (volatile int *)arg;
    parked_started++;
    int rc = qnx_futex(addr, FUTEX_WAIT, 7, NULL, NULL, 0);
    if (rc != 0)
        return (void *)1;
    assert(*addr == 99 || *addr == 7);
    return NULL;
}

static void test_wait_wake(void)
{
    pthread_t t1, t2;
    word = 0;

    assert(qnx_futex(&word, FUTEX_WAIT, 1, NULL, NULL, 0) == -1);

    pthread_create(&t1, NULL, waiter_thread, NULL);
    pthread_create(&t2, NULL, waiter_thread, NULL);
    usleep(100000);
    word = 99;
    int woke = qnx_futex(&word, FUTEX_WAKE, 1, NULL, NULL, 0);
    assert(woke == 1);
    woke = qnx_futex(&word, FUTEX_WAKE, 1, NULL, NULL, 0);
    assert(woke == 1);
    pthread_join(t1, NULL);
    pthread_join(t2, NULL);
    printf("wait/wake ok\n");
}

static void test_private_flag(void)
{
    volatile int w2 = 0;
    assert(qnx_futex(&w2, FUTEX_WAIT | FUTEX_PRIVATE_FLAG, 1, NULL, NULL, 0) == -1);
    printf("private flag ok\n");
}

static void test_cmp_requeue(void)
{
    pthread_t t[4];
    volatile int w1 = 7, w2 = 0;
    int i, n;
    void *res;

    for (i = 0; i < 4; i++)
        pthread_create(&t[i], NULL, parked_thread, (void *)&w1);
    while (parked_started < 4)
        usleep(10000);

    /* mismatch: EAGAIN, nothing moves */
    assert(qnx_futex(&w1, FUTEX_CMP_REQUEUE, 1, NULL, &w2, 4) == -1);

    /* wake 1, requeue the rest (count doubles as the expected value) */
    n = qnx_futex(&w1, FUTEX_CMP_REQUEUE, 1, NULL, &w2, 7);
    assert(n == 4);
    /* the woken one must exit on its own */
    /* w2 now holds 3 waiters; wake them */
    assert(qnx_futex(&w2, FUTEX_WAKE, 10, NULL, NULL, 0) == 3);

    for (i = 0; i < 4; i++) {
        pthread_join(t[i], &res);
        assert(res == NULL);
    }
    assert(qnx_futex(&w1, FUTEX_LOCK_PI, 0, NULL, NULL, 0) == -1);
    printf("cmp_requeue ok\n");
}

static void test_timed(void)
{
    struct timespec ts = {0, 50000000}; /* 50 ms */
    volatile int w = 0;
    int rc = qnx_futex(&w, FUTEX_WAIT, 0, &ts, NULL, 0);
    assert(rc == -1);
    printf("timed ok\n");
}

int main(void)
{
    test_wait_wake();
    test_private_flag();
    test_timed();
    test_cmp_requeue();
    printf("all futex shim tests passed\n");
    return 0;
}
