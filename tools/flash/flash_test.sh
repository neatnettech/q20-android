#!/bin/bash
# Seal-behavior test matrix: 4 tiny fake-rcfs containers in ONE loader session,
# each with a different 40F9 signature treatment. After the flash, boot and
# scan os0t179/os1t179 offset 0 for the Q20TESTn markers.
cd "$(dirname "$0")"
T=/private/var/folders/03/bdcsj20x1q372qfxl9pbffz40000gn/T/opencode/q20-rcfs
LOG=/private/var/folders/03/bdcsj20x1q372qfxl9pbffz40000gn/T/opencode/q20-flashtest.log
LOADER="$(dirname "$0")/loader_9600270A-00.bin"
SEAL=/Users/piotrpestka/github/q20-android/runtime/qnx-shims/door/reflash/install-seal-560.bin

have_bb() { python3 -c "import usb.core,sys;sys.exit(0 if usb.core.find(idVendor=0x0FCA) else 1)"; }
have_bootrom() { python3 -c "import usb.core,sys;sys.exit(0 if usb.core.find(idVendor=0x0FCA,idProduct=1) else 1)"; }

if ! have_bootrom; then
  echo "waiting for fresh bootrom edge $(date +%T)" >> "$LOG"
  while have_bb; do sleep 3; done
  while ! have_bootrom; do sleep 1; done
fi
echo "fresh 0001 at $(date +%T), flashing test matrix" >> "$LOG"
python3 -u bblink.py --loader "$LOADER" --password "${Q20_PW:?set Q20_PW}" flash \
  "$T/t1.signed:none" "$T/t2.signed:dummy" "$T/t3.signed:seal=$SEAL" "$T/t4.signed:none" \
  >> "$LOG" 2>&1 && echo "TESTFLASH-OK $(date +%T)" >> "$LOG" || echo "TESTFLASH-FAILED" >> "$LOG"
