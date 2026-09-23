/*
 * stdatomic.h stub for QNX C++ builds: the QNX toolchain's GCC-provided
 * stdatomic.h only works in C11 mode. In C++ we map the C11 names used by
 * AOSP's cutils onto std::atomic.
 */
#ifndef ART_QNX_STDATOMIC_STUB_H
#define ART_QNX_STDATOMIC_STUB_H

#ifdef __cplusplus
#include <atomic>

#define _Atomic(T) std::atomic<T>

typedef std::atomic<bool> atomic_bool;
typedef std::atomic<char> atomic_char;
typedef std::atomic<signed char> atomic_schar;
typedef std::atomic<unsigned char> atomic_uchar;
typedef std::atomic<short> atomic_short;
typedef std::atomic<unsigned short> atomic_ushort;
typedef std::atomic<int> atomic_int;
typedef std::atomic<unsigned int> atomic_uint;
typedef std::atomic<long> atomic_long;
typedef std::atomic<unsigned long> atomic_ulong;
typedef std::atomic<long long> atomic_llong;
typedef std::atomic<unsigned long long> atomic_ullong;
typedef std::atomic<int_least32_t> atomic_int_least32_t;
typedef std::atomic<uint_least32_t> atomic_uint_least32_t;
typedef std::atomic<intptr_t> atomic_intptr_t;
typedef std::atomic<uintptr_t> atomic_uintptr_t;

using std::memory_order_relaxed;
using std::memory_order_consume;
using std::memory_order_acquire;
using std::memory_order_release;
using std::memory_order_acq_rel;
using std::memory_order_seq_cst;

using std::atomic_init;
using std::atomic_load_explicit;
using std::atomic_store_explicit;
using std::atomic_fetch_add_explicit;
using std::atomic_fetch_sub_explicit;
using std::atomic_fetch_or_explicit;
using std::atomic_fetch_and_explicit;
using std::atomic_fetch_xor_explicit;
using std::atomic_exchange_explicit;
using std::atomic_compare_exchange_strong_explicit;
using std::atomic_compare_exchange_weak_explicit;
using std::atomic_thread_fence;
using std::atomic_signal_fence;

#else /* __cplusplus */
#error "QNX C mode stdatomic not provided; use the C++ stub"
#endif

#endif /* ART_QNX_STDATOMIC_STUB_H */
