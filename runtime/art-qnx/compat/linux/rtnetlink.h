/* linux/rtnetlink.h shim for QNX: define the AF_NETLINK socket addr types
 * used by OsConstants constants. */
#ifndef ART_QNX_LINUX_RTNETLINK_STUB_H
#define ART_QNX_LINUX_RTNETLINK_STUB_H
#include <stdint.h>
struct sockaddr_nl {
  uint16_t nl_family;
  uint16_t nl_pad;
  uint32_t nl_pid;
  uint32_t nl_groups;
};
#endif
