/*
 * QNX port compatibility header, force-included in every ART TU
 * (-include art_qnx_compat.h). AOSP headers rely on bionic's permissive
 * transitive includes; QNX's Dinkumware headers do not. Restore the common
 * C names ART uses unqualified.
 */
#ifndef ART_QNX_COMPAT_H
#define ART_QNX_COMPAT_H

#include <algorithm>
<<<<<<< HEAD
=======
#include <cstdarg>
>>>>>>> 6e0a8006 (Complete ART 6.0.1 QNX port: full runtime compiles and links as libart.so)
#include <cstring>
#include <cstdio>
#include <cstdlib>
#include <memory>
#include <strings.h>
#include <sys/mman.h>
#include <sys/time.h>
#include <unistd.h>

<<<<<<< HEAD
extern "C" int qnx_tgkill(int tgid, int tid, int sig);
extern "C" ssize_t sendfile(int out_fd, int in_fd, off_t *offset, size_t count);

=======
/* QNX libc lacks asprintf */
static inline int qnx_asprintf(char **strp, const char *fmt, ...)
{
    va_list ap, ap2;
    int n;
    va_start(ap, fmt);
    va_copy(ap2, ap);
    n = vsnprintf(NULL, 0, fmt, ap);
    va_end(ap);
    *strp = (char *)malloc(n + 1);
    vsnprintf(*strp, n + 1, fmt, ap2);
    va_end(ap2);
    return n;
}
#define asprintf qnx_asprintf

extern "C" int qnx_tgkill(int tgid, int tid, int sig);
extern "C" ssize_t sendfile(int out_fd, int in_fd, off_t *offset, size_t count);

/* QNX signal.h has no sighandler_t typedef */
typedef void (*qnx_sighandler_t)(int);
#define sighandler_t qnx_sighandler_t

>>>>>>> 6e0a8006 (Complete ART 6.0.1 QNX port: full runtime compiles and links as libart.so)
#ifdef __QNXNTO__
#include "qnx_sigcontext.h"
#endif

#define RUNNING_ON_VALGRIND 0

/* QNX elf.h has no ElfW convenience macro */
#ifndef ElfW
#define ElfW(type) Elf32_##type
#endif

/* EM_* machine constants QNX elf.h lacks (its EM_ARM/EM_386/EM_MIPS are
 * enums, do not redefine those) */
#ifndef EM_X86_64
#define EM_X86_64 62
#endif
#ifndef EM_AARCH64
#define EM_AARCH64 183
#endif
/* MIPS elf flags QNX elf.h lacks */
#ifndef EF_MIPS_ARCH
#define EF_MIPS_ARCH 0xf0000000
#endif
#ifndef EF_MIPS_ARCH_32R2
#define EF_MIPS_ARCH_32R2 0x70000000
#endif
#ifndef EF_MIPS_ARCH_32R6
#define EF_MIPS_ARCH_32R6 0x90000000
#endif
#ifndef EF_MIPS_ARCH_64R2
#define EF_MIPS_ARCH_64R2 0xa0000000
#endif
#ifndef EF_MIPS_ARCH_64R6
#define EF_MIPS_ARCH_64R6 0xc0000000
#endif

/* QNX signal semantics differences */
#ifndef SA_RESTART
#define SA_RESTART 0
#endif
/* QNX has no d_type in dirent */
#ifndef DT_UNKNOWN
#define DT_UNKNOWN 0
#endif
#ifndef DT_REG
#define DT_REG 8
#endif
#ifndef DT_DIR
#define DT_DIR 4
#endif
#ifndef DT_LNK
#define DT_LNK 10
#endif
/* QNX CMSG_ALIGN is a function call, not a constant; give CMSG_SPACE a
 * constant over-approximation (do not reuse CMSG_ALIGN, QNX redefines it) */
#ifndef CMSG_SPACE
#define CMSG_SPACE(len) (sizeof(struct cmsghdr) + 2 * sizeof(size_t) + (len))
#endif

/* QNX sigaction has no SA_ONSTACK (no alt stacks at all, see
 * runtime/patches/0001) */
#ifndef SA_ONSTACK
#define SA_ONSTACK 0
#endif

using std::memcpy;
using std::memmove;
using std::memset;
using std::memcmp;
using std::memchr;
using std::strlen;
using std::strcmp;
using std::strncmp;
using std::strcpy;
using std::strncpy;
using std::strcat;
using std::strncat;
using std::strchr;
using std::strrchr;
using std::strstr;
using std::strtol;
using std::strtoul;
using std::snprintf;

/* QNX declares these in the global namespace only */
using ::strdup;
using ::strcasecmp;
using ::strncasecmp;
using ::strtoll;
using ::strtoull;

/* QNX has posix_madvise, not madvise */
#ifndef MADV_DONTNEED
#define MADV_DONTNEED 4
#endif
#ifndef MADV_NORMAL
#define MADV_NORMAL 0
#endif
#ifndef MADV_RANDOM
#define MADV_RANDOM 1
#endif
#ifndef MADV_SEQUENTIAL
#define MADV_SEQUENTIAL 2
#endif
static inline int madvise(void *addr, size_t len, int advice)
{
    int a = POSIX_MADV_NORMAL;
    if (advice == MADV_DONTNEED)
        a = POSIX_MADV_DONTNEED;
    else if (advice == MADV_RANDOM)
        a = POSIX_MADV_RANDOM;
    else if (advice == MADV_SEQUENTIAL)
        a = POSIX_MADV_SEQUENTIAL;
    return posix_madvise(addr, len, a);
}

#endif /* ART_QNX_COMPAT_H */
