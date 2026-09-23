/* linux/if_addr.h shim for QNX */
#ifndef ART_QNX_LINUX_IF_ADDR_STUB_H
#define ART_QNX_LINUX_IF_ADDR_STUB_H
struct ifaddrmsg {
  unsigned char ifa_family;
  unsigned char ifa_prefixlen;
  unsigned char ifa_flags;
  unsigned char ifa_scope;
  unsigned int ifa_index;
};
#endif
