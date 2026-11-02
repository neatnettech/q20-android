#!/bin/bash
# Retry wrapper for the bblink flash lane: flash; on failure wait for a fresh
# bootrom edge (device must leave 0001, then reappear) and retry immediately,
# so the bootrom never sits parked long enough to go stale.
# usage: flash_retry.sh [files...]   (default: Classic OS+radio; P'9983:
#   flash_retry.sh ~/q20-flash/p9983/ifs.signed ~/q20-flash/p9983/os.signed \
#                 ~/q20-flash/p9983/radio.signed)
cd "$(dirname "$0")"
LOG=/private/var/folders/03/bdcsj20x1q372qfxl9pbffz40000gn/T/opencode/q20-flash.log
LOADER="$(dirname "$0")/loader_9600270A-00.bin"

have_bb() { python3 -c "import usb.core,sys;sys.exit(0 if usb.core.find(idVendor=0x0FCA) else 1)"; }
have_bootrom() { python3 -c "import usb.core,sys;sys.exit(0 if usb.core.find(idVendor=0x0FCA,idProduct=1) else 1)"; }

for attempt in 1 2 3 4 5; do
  if ! have_bootrom; then
    echo "no fresh bootrom $(date +%T); waiting for edge (unplug, press power, plug)" >> "$LOG"
    while have_bb; do sleep 3; done
    while ! have_bootrom; do sleep 1; done
    echo "fresh 0001 at $(date +%T)" >> "$LOG"
  fi
  echo "=== flash attempt $attempt $(date +%T) ===" >> "$LOG"
  if python3 -u bblink.py --loader "$LOADER" --password "${Q20_PW:?set Q20_PW}" flash \
       "$@" >> "$LOG" 2>&1; then
    echo "FLASH-OK $(date +%T)" >> "$LOG"
    exit 0
  fi
  echo "attempt $attempt failed $(date +%T); waiting for fresh bootrom edge (unplug, press power, plug)" >> "$LOG"
  while have_bb; do sleep 3; done          # device must disappear first
  while ! have_bootrom; do sleep 1; done   # then come back as fresh 0001
  echo "fresh 0001 at $(date +%T), retrying now" >> "$LOG"
done
echo "FLASH-FAILED after 5 attempts" >> "$LOG"
exit 1
