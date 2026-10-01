/*
 * QNX port stub for <endian.h> (glibc). QNX has no such header; the target
 * is always little endian armle-v7, and the htole and letoh families are
 * identity mappings.
 */
#ifndef ART_QNX_ENDIAN_H
#define ART_QNX_ENDIAN_H

#ifndef __BYTE_ORDER
#define __LITTLE_ENDIAN 1234
#define __BIG_ENDIAN 4321
#define __BYTE_ORDER __LITTLE_ENDIAN
#define LITTLE_ENDIAN __LITTLE_ENDIAN
#define BIG_ENDIAN __BIG_ENDIAN
#define BYTE_ORDER __LITTLE_ENDIAN
#endif

#ifndef htole16
#define htole16(x) (x)
#define le16toh(x) (x)
#define htole32(x) (x)
#define le32toh(x) (x)
#define htole64(x) (x)
#define le64toh(x) (x)
#endif

#endif  // ART_QNX_ENDIAN_H
