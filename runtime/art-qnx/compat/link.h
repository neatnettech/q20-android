/* link.h shim for QNX. The QNX 6.5 SDK headers have no dl_phdr_info and no
 * dl_iterate_phdr declaration, although the device libc exports the function
 * (verified on-device). sys/link.h is included for the link_map types; the
 * dl_phdr_info layout follows the Linux/QNX 6.6 ABI the device uses. */
#ifndef ART_QNX_LINK_STUB_H
#define ART_QNX_LINK_STUB_H
#include <sys/link.h>

struct dl_phdr_info {
    Elf32_Addr dlpi_addr;
    const char *dlpi_name;
    const Elf32_Phdr *dlpi_phdr;
    Elf32_Half dlpi_phnum;
    unsigned long long dlpi_adds;
    unsigned long long dlpi_subs;
    size_t dlpi_tls_modid;
    void *dlpi_tls_data;
};

#ifdef __cplusplus
extern "C" {
#endif
int dl_iterate_phdr(int (*cb)(struct dl_phdr_info *info, size_t size,
                              void *data), void *data);
#ifdef __cplusplus
}
#endif
#endif
