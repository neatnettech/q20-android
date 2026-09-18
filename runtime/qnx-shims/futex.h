#ifndef QNX_SHIMS_FUTEX_H
#define QNX_SHIMS_FUTEX_H

#include <time.h>

/*
 * qnx_futex: userland futex emulation for QNX, following the design of the
 * Q20 factory runtime's libbionic.so futex shim (global waiters list, one
 * condition variable per waiter), extended with FUTEX_CMP_REQUEUE which the
 * original shim returns ENOSYS for (verified by disassembly; see
 * docs/runtime-comparison.md section 4).
 *
 * Supported ops: FUTEX_WAIT, FUTEX_WAKE, FUTEX_CMP_REQUEUE, plus
 * FUTEX_WAIT_BITSET / FUTEX_WAKE_BITSET handled as WAIT / WAKE.
 * Everything else returns ENOSYS, matching the Q20 shim's behaviour.
 *
 * The private flag (128) is accepted and ignored: all futexes share one
 * namespace, exactly like the Q20 shim. This is sufficient for ART, which
 * only uses private futexes within a process.
 */

#define FUTEX_WAIT         0
#define FUTEX_WAKE         1
#define FUTEX_FD           2
#define FUTEX_REQUEUE      3
#define FUTEX_CMP_REQUEUE  4
#define FUTEX_WAKE_OP      5
#define FUTEX_LOCK_PI      6
#define FUTEX_UNLOCK_PI    7
#define FUTEX_TRYLOCK_PI   8
#define FUTEX_WAIT_BITSET  9
#define FUTEX_WAKE_BITSET 10

#define FUTEX_PRIVATE_FLAG 128

/* Linux compatible futex(2) signature. */
int qnx_futex(volatile void *addr, int op, int val,
              const struct timespec *timeout,
              volatile void *addr2, int val3);

#endif /* QNX_SHIMS_FUTEX_H */
