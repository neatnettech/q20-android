/*
 * QNX shim for system/core code: QNX has posix_madvise with POSIX_MADV_*
 * constants, no madvise(2) with MADV_*. Map the small set libziparchive and
 * FileMap use.
 */
#ifndef ART_QNX_ZIP_COMPAT_H
#define ART_QNX_ZIP_COMPAT_H

#include <sys/mman.h>

#if defined(__QNXNTO__)
#include <errno.h>
#include <string.h>
#include <sys/stat.h>

#define MADV_NORMAL POSIX_MADV_NORMAL
#define MADV_RANDOM POSIX_MADV_RANDOM
#define MADV_SEQUENTIAL POSIX_MADV_SEQUENTIAL
#define MADV_WILLNEED POSIX_MADV_WILLNEED
#define MADV_DONTNEED POSIX_MADV_DONTNEED

#ifndef DEFFILEMODE
#define DEFFILEMODE (S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH | S_IWOTH)
#endif

#ifndef O_NOFOLLOW
#define O_NOFOLLOW 0
#endif

static inline int madvise(void* addr, size_t length, int advice) {
  return posix_madvise(addr, length, advice);
}
#endif  // __QNXNTO__

#endif  // ART_QNX_ZIP_COMPAT_H
