/* byteswap.h shim for QNX */
#ifndef ART_QNX_BYTESWAP_STUB_H
#define ART_QNX_BYTESWAP_STUB_H
#define bswap_16(x) __builtin_bswap16(x)
#define bswap_32(x) __builtin_bswap32(x)
#define bswap_64(x) __builtin_bswap64(x)
#endif
