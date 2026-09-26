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
#include <cstdio>
#include <cstring>
#include <fcntl.h>
#include <unistd.h>

#include "link.h"

extern "C" {

/* QNX has no ashmem driver; back the region with a temporary file that is
 * immediately unlinked (same trick ART's own host builds use: files in
 * /tmp). Single-process semantics are enough for ART's GC spaces. */
static int finish_ashmem(char* tmpl, size_t size) {
  (void)size;
  // QNX GC bug experiment: back the region with /dev/zero (true anonymous
  // zeroed pages, no file semantics) instead of a flash temp file.
  int fd = open("/dev/zero", O_RDWR);
  return fd;
}

int ashmem_create_region(const char* name, size_t size) {
  (void)name;
  const char* data_dir = getenv("ANDROID_DATA");
  if (data_dir != nullptr && data_dir[0] != '\0') {
    // QNX /tmp is RAM backed; big GC regions must live on flash.
    char tmpl[256];
    snprintf(tmpl, sizeof(tmpl), "%s/tmp/ashmem-%d-XXXXXX", data_dir,
             static_cast<int>(getpid()));
    int fd = finish_ashmem(tmpl, size);
    if (fd >= 0) {
      return fd;
    }
  }
  char tmpl[128];
  snprintf(tmpl, sizeof(tmpl), "/tmp/ashmem-%d-XXXXXX", static_cast<int>(getpid()));
  return finish_ashmem(tmpl, size);
}

/* ---- dl_iterate_phdr for QNX ---- */
/* QNX has no dl_iterate_phdr in its SDK; implement it from /proc/self/mappings
 * (per-page lines, first field vaddr, last field pathname or {name}) plus the
 * program headers read from each mapped file. */

static int qnx_dl_iterate_cb(void* opaque, uint32_t start, uint32_t end,
                             const char* name);

struct qnx_iter_ctx {
  int (*cb)(struct dl_phdr_info*, size_t, void*);
  void* data;
};

int dl_iterate_phdr(int (*cb)(struct dl_phdr_info* info, size_t size, void* data),
                    void* data) {
  FILE* f = fopen("/proc/self/mappings", "r");
  if (f == nullptr) {
    return 0;
  }
  char line[512];
  char cur_name[256] = "";
  uint32_t cur_start = 0, cur_end = 0;
  int result = 0;

  struct qnx_iter_ctx ctx = { cb, data };

  while (fgets(line, sizeof(line), f) != nullptr) {
    unsigned int addr = 0;
    if (sscanf(line, "0x%x,", &addr) != 1) {
      continue;
    }
    /* name: last comma-separated field, possibly {name} (anonymous) */
    char* last = strrchr(line, ',');
    const char* name = nullptr;
    char namebuf[256];
    if (last != nullptr) {
      last++;
      if (*last == '{') {
        name = nullptr;  // anonymous
      } else {
        size_t n = strlen(last);
        while (n > 0 && (last[n-1] == '\n' || last[n-1] == '\r')) n--;
        memcpy(namebuf, last, n);
        namebuf[n] = '\0';
        name = namebuf;
      }
    }

    if (name != nullptr) {
      if (cur_name[0] != '\0' && strcmp(cur_name, name) == 0 &&
          addr == cur_end) {
        cur_end = addr + 0x1000;
        continue;
      }
      /* flush previous region */
      if (cur_name[0] != '\0') {
        int r = qnx_dl_iterate_cb(&ctx, cur_start, cur_end, cur_name);
        if (r != 0) {
          result = r;
          break;
        }
      }
      strncpy(cur_name, name, sizeof(cur_name) - 1);
      cur_name[sizeof(cur_name) - 1] = '\0';
      cur_start = addr;
      cur_end = addr + 0x1000;
    }
  }
  if (cur_name[0] != '\0' && result == 0) {
    result = qnx_dl_iterate_cb(&ctx, cur_start, cur_end, cur_name);
  }
  fclose(f);
  return result;
}

static int qnx_dl_iterate_cb(void* opaque, uint32_t start, uint32_t end,
                             const char* name) {
  struct qnx_iter_ctx* ctx = (struct qnx_iter_ctx*)opaque;
  /* Read the program headers directly from the mapped memory: QNX's procfs
   * pathnames can be stale (renamed files), so fopen would fail. The first
   * LOAD segment covers file offset 0, i.e. the ELF header is at `start`. */
  const unsigned char* ehdr = (const unsigned char*)(uintptr_t)start;
  if (ehdr[0] != 0x7f || ehdr[1] != 'E' || ehdr[2] != 'L' || ehdr[3] != 'F') {
    return 0;
  }
  uint32_t e_phoff;
  uint16_t e_phentsize, e_phnum;
  memcpy(&e_phoff, ehdr + 28, 4);
  memcpy(&e_phentsize, ehdr + 42, 2);
  memcpy(&e_phnum, ehdr + 44, 2);
  if (e_phnum == 0 || e_phentsize != 32) {
    return 0;
  }
  if (e_phoff + (uint32_t)e_phnum * 32 > (end - start)) {
    return 0;
  }
  unsigned char* phdrs = (unsigned char*)malloc((size_t)e_phnum * 32);
  if (phdrs == nullptr) {
    return 0;
  }
  memcpy(phdrs, ehdr + e_phoff, (size_t)e_phnum * 32);

  /* load bias from the first PT_LOAD; page-align segments to mirror the
   * actual kernel mappings (ART's CheckNoGaps needs them to tile exactly) */
  uint32_t bias = 0;
  int have_load = 0;
  for (int i = 0; i < e_phnum; i++) {
    uint32_t p_type = *(uint32_t*)(phdrs + i * 32);
    if (p_type == 1) {  // PT_LOAD
      uint32_t p_vaddr = *(uint32_t*)(phdrs + i * 32 + 8);
      if (!have_load) {
        bias = start - p_vaddr;
        have_load = 1;
      }
    }
  }

  /* rewrite the phdr copy with page-aligned vaddr/memsz */
  for (int i = 0; i < e_phnum; i++) {
    uint32_t p_type = *(uint32_t*)(phdrs + i * 32);
    if (p_type == 1) {
      uint32_t p_vaddr = *(uint32_t*)(phdrs + i * 32 + 8);
      uint32_t p_memsz = *(uint32_t*)(phdrs + i * 32 + 20);
      uint32_t aligned_vaddr = p_vaddr & ~0xfffu;
      uint32_t aligned_end = (p_vaddr + p_memsz + 0xfff) & ~0xfffu;
      *(uint32_t*)(phdrs + i * 32 + 8) = aligned_vaddr;
      *(uint32_t*)(phdrs + i * 32 + 20) = aligned_end - aligned_vaddr;
    }
  }

  /* recompute bias from the (possibly aligned) first PT_LOAD */
  for (int i = 0; i < e_phnum; i++) {
    uint32_t p_type = *(uint32_t*)(phdrs + i * 32);
    if (p_type == 1) {
      bias = start - *(uint32_t*)(phdrs + i * 32 + 8);
      break;
    }
  }

  struct dl_phdr_info info;
  memset(&info, 0, sizeof(info));
  info.dlpi_addr = bias;
  info.dlpi_name = name;
  /* phdr array must be Elf32_Phdr (32 bytes); pass the raw buffer */
  info.dlpi_phdr = (const Elf32_Phdr*)phdrs;
  info.dlpi_phnum = (Elf32_Half)e_phnum;
  int ret = ctx->cb(&info, sizeof(info), ctx->data);
  free(phdrs);
  return ret;
}

}  // extern "C"
