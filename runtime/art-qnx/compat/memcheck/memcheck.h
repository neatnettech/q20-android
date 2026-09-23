/* memcheck.h stub for QNX: no valgrind */
#ifndef ART_QNX_MEMCHECK_STUB_H
#define ART_QNX_MEMCHECK_STUB_H
#define VALGRIND_MAKE_MEM_DEFINED_IF_ADDRESSABLE(addr, len)
#define VALGRIND_MAKE_MEM_UNDEFINED(addr, len)
#define VALGRIND_MAKE_MEM_NOACCESS(addr, len)
#define VALGRIND_CHECK_MEM_IS_ADDRESSABLE(addr, len) (0)
#define VALGRIND_CHECK_VALUE_IS_DEFINED(x) (0)
#endif
