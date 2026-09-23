#include <pthread.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

/*
 * QNX guard-page signal delivery probe v2.
 *
 * v1 finding: with longjmp in the handler, the overflowing thread spins
 * forever (stack kept growing, guard never hit, or delivery wedged). This
 * version: no longjmp, the handler records the fault and exits the process
 * directly, recursion is capped so we can tell "no fault fired" from
 * "fault wedged the thread".
 */

static volatile sig_atomic_t handled = 0;
static volatile void *fault_addr;
static volatile unsigned long frames = 0;
static volatile int done = 0;

#define MAX_FRAMES 2000000UL

static void segv_handler(int sig, siginfo_t *si, void *uctx)
{
    (void)sig;
    (void)uctx;
    fault_addr = si->si_addr;
    handled = 1;
    _exit(0);
}

static void deep(void)
{
    volatile char pad[128];
    pad[0] = 1;
    frames++;
    if (frames >= MAX_FRAMES)
        _exit(2);
    deep();
    /* work after the call: defeats sibling-call optimization, forces a
     * real stack frame per level */
    pad[0] += 1;
}

static void *thread_fn(void *arg)
{
    (void)arg;
    deep();
    done = 1;
    return NULL;
}

static void run_case(size_t stacksz, size_t guardsz, const char *name)
{
    pthread_t t;
    pthread_attr_t attr;
    int rc;

    handled = 0;
    frames = 0;
    fault_addr = NULL;
    done = 0;

    pthread_attr_init(&attr);
    pthread_attr_setstacksize(&attr, stacksz);
    pthread_attr_setguardsize(&attr, guardsz);
#ifdef __QNXNTO__
    /* QNX grows stacks lazily; turn that off so the guard actually bites */
    pthread_attr_setstacklazy(&attr, 0);
#endif
    printf("  case %s: ", name);
    fflush(stdout);
    rc = pthread_create(&t, &attr, thread_fn, NULL);
    if (rc != 0) {
        printf("pthread_create failed rc=%d\n", rc);
        pthread_attr_destroy(&attr);
        return;
    }
    pthread_join(t, NULL);
    pthread_attr_destroy(&attr);
    if (handled) {
        printf("HANDLER RAN, fault=%p\n", (void *)fault_addr);
    } else if (frames >= MAX_FRAMES) {
        printf("NO FAULT after %lu frames (stack grows, guard not hit)\n",
               frames);
    } else {
        printf("thread exited, no fault (frames=%lu)\n", frames);
    }
}

int main(void)
{
    struct sigaction sa;

    setvbuf(stdout, NULL, _IONBF, 0);

    memset(&sa, 0, sizeof(sa));
    sa.sa_sigaction = segv_handler;
    sa.sa_flags = SA_SIGINFO;
    sigemptyset(&sa.sa_mask);
    sigaction(SIGSEGV, &sa, NULL);

    printf("QNX guard page signal delivery probe v2\n");
    run_case(64 * 1024, 16 * 1024, "64K stack + 16K guard");
    run_case(64 * 1024, 0, "64K stack no guard");
    printf("done\n");
    return 0;
}
