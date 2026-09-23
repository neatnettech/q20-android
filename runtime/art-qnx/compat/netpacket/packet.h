/* netpacket/packet.h shim for QNX */
#ifndef ART_QNX_NETPACKET_PACKET_STUB_H
#define ART_QNX_NETPACKET_PACKET_STUB_H
#include <stdint.h>
struct sockaddr_ll {
  uint16_t sll_family;
  uint16_t sll_protocol;
  int sll_ifindex;
  uint16_t sll_hatype;
  uint8_t sll_pkttype;
  uint8_t sll_halen;
  uint8_t sll_addr[8];
};
#endif
