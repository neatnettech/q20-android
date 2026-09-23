#include "futex.h"

#include <dlfcn.h>
#include <pthread.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

/*
 * On-device probe: runs the futex shim self-checks, then dlsym-probes the
 * device's own libc for the symbols ART 6 needs (see
 * docs/runtime-comparison.md section 5).
 */

static volatile int word = 0;

static void *waiter(void *arg)
{
    int id = (int)(long)arg;
    int rc = qnx_futex(&word, FUTEX_WAIT, id, NULL, NULL, 0);
    if (rc != 0)
        return (void *)1;
    return NULL;
}

static int futex_selfcheck(void)
{
    pthread_t t1, t2;
    void *res;
    struct timespec ts = {0, 20000000};
    volatile int w1 = 7, w2 = 0;

    word = 0;
    if (qnx_futex(&word, FUTEX_WAIT, 1, NULL, NULL, 0) != -1)
        return 1;
    word = 1;
    pthread_create(&t1, NULL, waiter, (void *)1);
    pthread_create(&t2, NULL, waiter, (void *)1);
    usleep(50000);
    word = 2;
    if (qnx_futex(&word, FUTEX_WAKE, 2, NULL, NULL, 0) != 2)
        return 2;
    pthread_join(t1, &res);
    if (res != NULL)
        return 3;
    pthread_join(t2, &res);
    if (res != NULL)
        return 4;

    /* timed wait times out */
    w1 = 0;
    if (qnx_futex(&w1, FUTEX_WAIT, 0, &ts, NULL, 0) != -1)
        return 5;

    /* cmp_requeue: 4 parked, wake 1, requeue 3 */
    word = 7;
    pthread_create(&t1, NULL, waiter, (void *)7);
    pthread_create(&t2, NULL, waiter, (void *)7);
    usleep(50000);
    if (qnx_futex(&word, FUTEX_CMP_REQUEUE, 1, NULL, &w2, 7) != 2)
        return 6;
    if (qnx_futex(&w2, FUTEX_WAKE, 4, NULL, NULL, 0) != 1)
        return 7;
    pthread_join(t1, &res);
    if (res != NULL)
        return 8;
    pthread_join(t2, &res);
    if (res != NULL)
        return 9;
    return 0;
}

static const char *probes[] = {
    "sigaltstack",
    "futex",
    "tgkill",
    "prctl",
    "clock_gettime",
    "clock_getres",
    "clock_nanosleep",
    "gettid",
    "pthread_getname_np",
    "pthread_setname_np",
    "dl_iterate_phdr",
    "dladdr",
    "posix_madvise",
    "madvise",
    "inotify_init",
    "inotify_add_watch",
    "inotify_rm_watch",
    "sched_getparam",
    "sched_setscheduler",
    "timer_create",
    "timerfd_create",
    "signal",
    "sigaction",
    "mmap",
    "munmap",
    "mem_offset64",
    "shm_open",
    "posix_fallocate",
    NULL,
};

int main(void)
{
    int i;
    printf("q20-probe: QNX armle shim test\n");
    int rc = futex_selfcheck();
    printf("futex selfcheck: %s (rc=%d)\n", rc == 0 ? "PASS" : "FAIL", rc);

    printf("--- device libc symbol probe ---\n");
    for (i = 0; probes[i] != NULL; i++) {
        void *p = dlsym(RTLD_DEFAULT, probes[i]);
        printf("  %-24s %s\n", probes[i], p != NULL ? "present" : "missing");
    }
    return rc == 0 ? 0 : 1;
}
