#include "proc.h"

#include <errno.h>

#ifdef __QNXNTO__
#include <sys/neutrino.h>
#include <sys/netmgr.h>
#endif

/*
 * tgkill(tgid, tid, sig): send sig to thread tid of process tgid.
 * QNX SignalKill(nd, pid, tid, signo, code, value) matches the semantics
 * when nd = ND_LOCAL_NODE.
 */
int qnx_tgkill(int tgid, int tid, int sig)
{
#ifdef __QNXNTO__
    return SignalKill(ND_LOCAL_NODE, tgid, tid, sig, 0, 0);
#else
    (void)tgid;
    (void)tid;
    (void)sig;
    errno = ENOSYS;
    return -1;
#endif
}

/*
 * prctl: only the options ART 6 uses are implemented. PR_SET_DUMPABLE is a
 * no-op success on QNX (no core dump policy to toggle). Everything else is
 * ENOSYS so callers fail loudly rather than silently misbehave.
 */
int qnx_prctl(int option, unsigned long arg2, unsigned long arg3,
              unsigned long arg4, unsigned long arg5)
{
    (void)arg2;
    (void)arg3;
    (void)arg4;
    (void)arg5;
    if (option == PR_SET_DUMPABLE)
        return 0;
    errno = ENOSYS;
    return -1;
}
