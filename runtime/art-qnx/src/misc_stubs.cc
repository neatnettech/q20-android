/*
 * QNX port: misc kernel-interface stubs.
 *
 * ponytail entries:
 * - ashmem_create_region: no ashmem driver on QNX; the Q20 runtime used
 *   mmap_peer instead. Return -1 so MemMap falls back to plain maps.
 * - dl_iterate_phdr: the device libc exports this but the 6.5 link-time
 *   libc does not; empty iteration until the link-map walk is ported.
 */

#include <cstddef>

#include "link.h"

extern "C" {

int ashmem_create_region(const char* name, size_t size) {
  (void)name;
  (void)size;
  return -1;
}

int dl_iterate_phdr(int (*cb)(struct dl_phdr_info* info, size_t size, void* data),
                    void* data) {
  (void)cb;
  (void)data;
  return 0;
}

}  // extern "C"
