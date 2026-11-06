#!/bin/sh
# q20usb-net: keep the Q20 USB link alive and at the address the device expects.
# The device's USB iface is 169.254.0.1/30 - it only talks to 169.254.0.2.
# macOS otherwise self-assigns a /16 the Q20 cannot route to, re-does it on
# every reseat, and sometimes the link wedges with no carrier (bounce fixes it).
#
#   sudo -v && sudo sh tools/flash/q20usb-net.sh &
#   (stop: sudo pkill -f q20usb-net)
while :; do
  for IF in $(networksetup -listallhardwareports 2>/dev/null | awk '/BlackBerry/{getline; print $2}'); do
    if ifconfig "$IF" 2>/dev/null | grep -q "status: active"; then
      ifconfig "$IF" | grep -q "inet 169.254.0.2 " \
        || ifconfig "$IF" inet 169.254.0.2 netmask 255.255.255.252 2>/dev/null
    else
      # no carrier: bounce the interface to re-trigger the gadget link,
      # then give it 15s to negotiate before the next bounce
      ifconfig "$IF" down 2>/dev/null; sleep 1; ifconfig "$IF" up 2>/dev/null; sleep 15
    fi
  done
  sleep 2
done
