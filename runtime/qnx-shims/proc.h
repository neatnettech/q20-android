#ifndef QNX_SHIMS_PROC_H
#define QNX_SHIMS_PROC_H

/*
 * Small bionic-to-QNX process/thread shims missing from the Q20 runtime.
 * See docs/runtime-comparison.md section 5: ART calls tgkill (Runtime::Abort)
 * and prctl(PR_SET_DUMPABLE) (ZygoteHooks).
 */

#define PR_SET_DUMPABLE 4
#define PR_SET_NAME     15

int qnx_tgkill(int tgid, int tid, int sig);
int qnx_prctl(int option, unsigned long arg2, unsigned long arg3,
              unsigned long arg4, unsigned long arg5);

#endif /* QNX_SHIMS_PROC_H */
