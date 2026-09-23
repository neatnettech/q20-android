/*
 * QNX port: operator new instrumentation (temporary).
 *
 * Logs every allocation over 8 MiB and any failure, so an OOM during boot
 * names the allocation size. Remove once the port stabilizes.
 */

#include <cstdio>
#include <cstdlib>
#include <cstdint>
#include <dlfcn.h>
#include <new>

static void print_caller(const char* what, size_t size, void* ra) {
  Dl_info info;
  uintptr_t addr = reinterpret_cast<uintptr_t>(ra) & ~1u;  // clear thumb bit
  if (dladdr(reinterpret_cast<void*>(addr), &info) != 0) {
    fprintf(stderr, "art-alloc: %s(%zu) from %s+0x%x (%s)\n", what, size,
            info.dli_fname != nullptr ? info.dli_fname : "?",
            (unsigned)(addr - reinterpret_cast<uintptr_t>(info.dli_fbase)),
            info.dli_sname != nullptr ? info.dli_sname : "?");
  } else {
    fprintf(stderr, "art-alloc: %s(%zu) from %p\n", what, size, ra);
  }
}

void* operator new(size_t size) {
  if (size >= (8u << 20)) {
    print_caller("new", size, __builtin_return_address(0));
  }
  void* p = malloc(size);
  if (p == nullptr) {
    print_caller("FAILED", size, __builtin_return_address(0));
  }
  return p;
}

void operator delete(void* p) noexcept {
  free(p);
}

void* operator new[](size_t size) {
  void* lr = nullptr;
#if defined(__arm__)
  __asm__ volatile("mov %0, lr" : "=r"(lr));
#endif
  if (size >= (8u << 20)) {
    print_caller("new[]", size, lr);
  }
  return operator new(size);
}

void operator delete[](void* p) noexcept {
  free(p);
}
