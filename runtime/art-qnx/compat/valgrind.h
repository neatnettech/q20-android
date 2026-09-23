/*
 * valgrind.h stub for QNX builds: no valgrind, so all VALGRIND_* macros are
 * no-ops and RUNNING_ON_VALGRIND is 0. ART uses these in malloc_space.h,
 * mem_map.h, and runtime.cc.
 */
#ifndef ART_QNX_VALGRIND_STUB_H
#define ART_QNX_VALGRIND_STUB_H

#define RUNNING_ON_VALGRIND 0

#define VALGRIND_MALLOCLIKE_BLOCK(addr, sizeB, rzB, is_zeroed)
#define VALGRIND_FREELIKE_BLOCK(addr, rzB)
#define VALGRIND_RESIZEINPLACE_BLOCK(addr, oldSizeB, newSizeB, rzB)
#define VALGRIND_MAKE_MEM_NOACCESS(addr, len)
#define VALGRIND_MAKE_MEM_UNDEFINED(addr, len)
#define VALGRIND_MAKE_MEM_DEFINED(addr, len)
#define VALGRIND_CREATE_MEMPOOL(pool, rzB, is_zeroed)
#define VALGRIND_DESTROY_MEMPOOL(pool)
#define VALGRIND_MEMPOOL_ALLOC(pool, addr, size)
#define VALGRIND_MEMPOOL_FREE(pool, addr)
#define VALGRIND_NON_SIMD_CALL0(fn)
#define VALGRIND_NON_SIMD_CALL1(fn, a1)
#define VALGRIND_NON_SIMD_CALL2(fn, a1, a2)
#define VALGRIND_NON_SIMD_CALL3(fn, a1, a2, a3)

#endif /* ART_QNX_VALGRIND_STUB_H */
