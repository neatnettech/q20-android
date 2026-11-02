#!/bin/bash
# Radio-only flash: ends the loader session with a successful commit (4006),
# which is what clears the red-blink boot block (session 9b: "flashing radio
# cleared it").
cd "$(dirname "$0")"
LOG=/private/var/folders/03/bdcsj20x1q372qfxl9pbffz40000gn/T/opencode/q20-radiofix.log
LOADER="$(dirname "$0")/loader_9600270A-00.bin"

have_bb() { python3 -c "import usb.core,sys;sys.exit(0 if usb.core.find(idVendor=0x0FCA) else 1)"; }
have_bootrom() { python3 -c "import usb.core,sys;sys.exit(0 if usb.core.find(idVendor=0x0FCA,idProduct=1) else 1)"; }

for attempt in 1 2 3; do
  if ! have_bootrom; then
    echo "waiting for bootrom edge $(date +%T)" >> "$LOG"
    while have_bb; do sleep 3; done
    while ! have_bootrom; do sleep 1; done
  fi
  echo "=== radio flash attempt $attempt $(date +%T) ===" >> "$LOG"
  if python3 -u bblink.py --loader "$LOADER" --password "${Q20_PW:?set Q20_PW}" flash ~/q20-flash/radio.signed >> "$LOG" 2>&1; then
    echo "RADIO-FLASH-OK $(date +%T)" >> "$LOG"
    exit 0
  fi
  echo "attempt $attempt failed" >> "$LOG"
done
exit 1
