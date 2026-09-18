#include "futex.h"

#include <errno.h>
#include <pthread.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

typedef struct waiter {
    struct waiter *next;
    pthread_cond_t cond;
    int woke;
} waiter_t;

typedef struct fq {
    struct fq *next;
    uintptr_t key;
    waiter_t *waiters;
} fq_t;

static pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;
static fq_t *queues = NULL;

static fq_t *find_q(uintptr_t key)
{
    fq_t *q;
    for (q = queues; q != NULL; q = q->next)
        if (q->key == key)
            return q;
    return NULL;
}

static fq_t *get_q(uintptr_t key)
{
    fq_t *q = find_q(key);
    if (q != NULL)
        return q;
    q = calloc(1, sizeof(*q));
    if (q == NULL)
        return NULL;
    q->key = key;
    q->next = queues;
    queues = q;
    return q;
}

static int timed_wait(waiter_t *w, const struct timespec *timeout)
{
    if (timeout != NULL)
        return pthread_cond_timedwait(&w->cond, &lock, timeout);
    pthread_cond_wait(&w->cond, &lock);
    return 0;
}

int qnx_futex(volatile void *addr, int op, int val,
              const struct timespec *timeout,
              volatile void *addr2, int val3)
{
    int rv = 0;
    fq_t *q, *q2;
    waiter_t *w;
    int moved = 0;

    (void)rv;
    (void)op;
    op &= ~FUTEX_PRIVATE_FLAG;

    switch (op) {
    case FUTEX_WAIT:
    case FUTEX_WAIT_BITSET:
        pthread_mutex_lock(&lock);
        if (*(volatile int *)addr != val) {
            pthread_mutex_unlock(&lock);
            errno = EAGAIN;
            return -1;
        }
        q = get_q((uintptr_t)addr);
        if (q == NULL) {
            pthread_mutex_unlock(&lock);
            errno = ENOMEM;
            return -1;
        }
        w = calloc(1, sizeof(*w));
        if (w == NULL) {
            pthread_mutex_unlock(&lock);
            errno = ENOMEM;
            return -1;
        }
        pthread_cond_init(&w->cond, NULL);
        w->next = q->waiters;
        q->waiters = w;
        while (!w->woke) {
            if (timed_wait(w, timeout) != 0) {
                waiter_t **pp = &q->waiters;
                while (*pp != NULL && *pp != w)
                    pp = &(*pp)->next;
                if (*pp == w)
                    *pp = w->next;
                pthread_mutex_unlock(&lock);
                pthread_cond_destroy(&w->cond);
                free(w);
                errno = ETIMEDOUT;
                return -1;
            }
        }
        pthread_mutex_unlock(&lock);
        pthread_cond_destroy(&w->cond);
        free(w);
        return 0;

    case FUTEX_WAKE:
    case FUTEX_WAKE_BITSET:
        pthread_mutex_lock(&lock);
        q = find_q((uintptr_t)addr);
        moved = 0;
        while (q != NULL && q->waiters != NULL && moved < val) {
            w = q->waiters;
            q->waiters = w->next;
            w->woke = 1;
            pthread_cond_signal(&w->cond);
            moved++;
        }
        pthread_mutex_unlock(&lock);
        return moved;

    case FUTEX_CMP_REQUEUE:
        if (timeout != NULL) {
            errno = ENOSYS;
            return -1;
        }
        pthread_mutex_lock(&lock);
        if (*(volatile int *)addr != val3) {
            pthread_mutex_unlock(&lock);
            errno = EAGAIN;
            return -1;
        }
        q = find_q((uintptr_t)addr);
        q2 = get_q((uintptr_t)addr2);
        if (q2 == NULL) {
            pthread_mutex_unlock(&lock);
            errno = ENOMEM;
            return -1;
        }
        while (q != NULL && q->waiters != NULL && moved < val) {
            w = q->waiters;
            q->waiters = w->next;
            w->woke = 1;
            pthread_cond_signal(&w->cond);
            moved++;
        }
        while (q != NULL && q->waiters != NULL && val3 > 0) {
            w = q->waiters;
            q->waiters = w->next;
            w->next = q2->waiters;
            q2->waiters = w;
            val3--;
            moved++;
        }
        pthread_mutex_unlock(&lock);
        return moved;

    default:
        errno = ENOSYS;
        return -1;
    }
}
