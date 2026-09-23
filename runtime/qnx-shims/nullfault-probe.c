#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*
 * Null pointer fault delivery probe: ART's implicit null checks rely on
 * SIGSEGV delivery when compiled code reads near address 0 with a valid SP.
 */
static void segv_handler(int sig, siginfo_t *si, void *uctx)
{
    (void)sig;
    (void)uctx;
    printf("HANDLER RAN fault=%p\n", si->si_addr);
    _exit(0);
}

int main(void)
{
    struct sigaction sa;

    memset(&sa, 0, sizeof(sa));
    sa.sa_sigaction = segv_handler;
    sa.sa_flags = SA_SIGINFO;
    sigemptyset(&sa.sa_mask);
    sigaction(SIGSEGV, &sa, NULL);

    printf("touching NULL...\n");
    fflush(stdout);
    volatile int *p = (int *)0;
    *p = 1;
    printf("no fault?!\n");
    return 1;
}
