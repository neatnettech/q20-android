/*
 * QNX port compatibility header, force-included in every ART TU
 * (-include art_qnx_compat.h). AOSP headers rely on bionic's permissive
 * transitive includes; QNX's Dinkumware headers do not. Restore the common
 * C names ART uses unqualified.
 */
#ifndef ART_QNX_COMPAT_H
#define ART_QNX_COMPAT_H

#include <algorithm>
#include <cstdarg>
#include <cstring>
#include <cstdio>
#include <cstdlib>
#include <memory>
#include <strings.h>
#include <sys/mman.h>
#include <sys/time.h>
#include <unistd.h>

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

/* getaddrinfo flags QNX netdb lacks (glibc/bionic values) */
#ifndef AI_V4MAPPED
#define AI_V4MAPPED 8
#endif
/* O_NOFOLLOW not on QNX fcntl */
#ifndef O_NOFOLLOW
#define O_NOFOLLOW 0
#endif
/* rt scope ids */
#ifndef RT_SCOPE_UNIVERSE
#define RT_SCOPE_UNIVERSE 0
#define RT_SCOPE_SITE 200
#define RT_SCOPE_LINK 253
#define RT_SCOPE_HOST 254
#define RT_SCOPE_NOWHERE 255
#endif

/* ARP hardware types */
#ifndef ARPHRD_LOOPBACK
#define ARPHRD_LOOPBACK 772
#endif
#ifndef ARPHRD_ETHER
#define ARPHRD_ETHER 1
#endif
/* netlink protocol ids */
#ifndef NETLINK_ROUTE
#define NETLINK_ROUTE 0
#endif
#ifndef NETLINK_KOBJECT_UEVENT
#define NETLINK_KOBJECT_UEVENT 15
#endif

/* QNX lacks these syscall wrappers */
static inline int pipe2(int* fds, int flags) {
  (void)flags;
  return pipe(fds);
}
static inline int prctl(int option, ...) { (void)option; return -1; }

/* getaddrinfo flags QNX netdb lacks (glibc/bionic values) */
#ifndef AI_ADDRCONFIG
#define AI_ADDRCONFIG 32
#endif
#ifndef AI_ALL
#define AI_ALL 16
#endif
#ifndef AI_NUMERICSERV
#define AI_NUMERICSERV 1024
#endif

/* QNX has no xattr family; report unsupported */
#include <sys/types.h>
static inline int getxattr(const char*, const char*, void*, size_t) { return -1; }
static inline int lgetxattr(const char*, const char*, void*, size_t) { return -1; }
static inline int fgetxattr(int, const char*, void*, size_t) { return -1; }
static inline int setxattr(const char*, const char*, const void*, size_t, int) { return -1; }
static inline int lsetxattr(const char*, const char*, const void*, size_t, int) { return -1; }
static inline int fsetxattr(int, const char*, const void*, size_t, int) { return -1; }
static inline int listxattr(const char*, char*, size_t) { return -1; }
static inline int llistxattr(const char*, char*, size_t) { return -1; }
static inline int flistxattr(int, char*, size_t) { return -1; }
static inline int removexattr(const char*, const char*) { return -1; }
static inline int lremovexattr(const char*, const char*) { return -1; }
static inline int fremovexattr(int, const char*) { return -1; }

/* rtnetlink multicast groups (glibc values) */
#ifndef RTMGRP_IPV4_IFADDR
#define RTMGRP_IPV4_IFADDR 0x10
#define RTMGRP_IPV4_MROUTE 0x20
#define RTMGRP_IPV6_IFADDR 0x100
#define RTMGRP_IPV6_MROUTE 0x200
#define RTMGRP_IPV4_ROUTE 0x40
#define RTMGRP_IPV4_RULE 0x80
#define RTMGRP_IPV6_IFINFO 0x800
#define RTMGRP_IPV6_ROUTE 0x400
#define RTMGRP_IPV6_PREFIX 0x20000
#define RTMGRP_LINK 1
#define RTMGRP_NEIGH 4
#define RTMGRP_TC 8
#define RTMGRP_NOTIFY 2
#define RTMGRP_DECnet_IFADDR 0x1000
#define RTMGRP_DECnet_ROUTE 0x4000
#endif
/* mount flags QNX lacks (statfs constants) */
#ifndef ST_MANDLOCK
#define ST_MANDLOCK 0x40
#endif
#ifndef ST_NOATIME
#define ST_NOATIME 0x400
#endif
#ifndef ST_NODIRATIME
#define ST_NODIRATIME 0x800
#endif
#ifndef ST_RELATIME
#define ST_RELATIME 0x1000
#endif
#ifndef ST_NODEV
#define ST_NODEV 0x4
#endif
#ifndef ST_SYNCHRONOUS
#define ST_SYNCHRONOUS 0x10
#endif
#ifndef ST_NOEXEC
#define ST_NOEXEC 0x8
#endif
#ifndef ST_NOSUID
#define ST_NOSUID 0x2
#endif

/* multicast group req structs QNX lacks */
#include <sys/socket.h>
struct group_req {
  uint32_t gr_interface;
  struct sockaddr_storage gr_group;
};
struct group_source_req {
  uint32_t gsr_interface;
  struct sockaddr_storage gsr_group;
  struct sockaddr_storage gsr_source;
};

/* QNX has ip_mreq, not ip_mreqn */
#include <netinet/in.h>
struct ip_mreqn {
  struct in_addr imr_multiaddr;
  struct in_addr imr_address;
  int imr_ifindex;
};

/* BSD type QNX lacks */
#ifndef __QNX_U_INT32_T
#define __QNX_U_INT32_T
typedef unsigned int u_int32_t;
#endif
/* ELF OSABI constant QNX elf.h lacks */
#ifndef ELFOSABI_LINUX
#define ELFOSABI_LINUX 3
#endif

/* QNX has no ucred (peer credentials) */
struct ucred {
  int pid;
  int uid;
  int gid;
};

/* Linux socket families QNX lacks */
#ifndef AF_NETLINK
#define AF_NETLINK 16
#endif
#ifndef AF_PACKET
#define AF_PACKET 17
#endif
#ifndef SOL_NETLINK
#define SOL_NETLINK 270
#endif

/* QNX signal names differ from glibc/bionic */
#ifndef __SIGRTMIN
#define __SIGRTMIN SIGRTMIN
#endif
#ifndef __SIGRTMAX
#define __SIGRTMAX SIGRTMAX
#endif

/* QNX signal.h has no sighandler_t typedef */
typedef void (*qnx_sighandler_t)(int);
#define sighandler_t qnx_sighandler_t

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
/* QNX libc has no strndup/strnlen */
static inline size_t strnlen(const char* s, size_t maxlen) {
  size_t i = 0;
  while (i < maxlen && s[i] != '\0') i++;
  return i;
}
static inline char* strndup(const char* s, size_t n) {
  size_t len = strnlen(s, n);
  char* p = (char*)malloc(len + 1);
  if (p != nullptr) {
    memcpy(p, s, len);
    p[len] = '\0';
  }
  return p;
}
using ::strncasecmp;
using ::strtoll;
using ::strtoull;

/* QNX has no mincore; report all resident */
static inline int mincore(void* addr, size_t length, unsigned char* vec) {
  (void)addr;
  size_t n = (length + 4095) / 4096;
  for (size_t i = 0; i < n; i++) vec[i] = 1;
  return 0;
}

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
