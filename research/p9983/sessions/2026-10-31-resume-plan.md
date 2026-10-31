# Session 2026-10-31 — P'9983 resume plan

Device parked charging (the bootrom power-cycles on USB-only power when the
battery is flat). Everything needed for the recovery is ready:

## Resume steps

1. **Charge** (battery in, 45-60 min, ideally a wall charger). Symptom to
   watch for: solid bootrom edge after the ritual (not 0.1-11s power-cycles).
2. **Flash** — the macOS lane is proven on this device's bootrom
   (8F00270A):
   ```
   cd tools/flash && ./watch_flash.py \
     ~/q20-flash/p9983/ifs.signed \
     ~/q20-flash/p9983/os.signed \
     ~/q20-flash/p9983/radio.signed
   ```
   (ritual: unplug → power off until dark → plug, touch nothing). The
   `set_configuration(1)` fix is already in bblink.py — the handshake
   issue that stalled every loader is solved.
3. **Boot** → setup wizard → WiFi → Dev Mode (password `drstone`).
4. **Root** — the same runtime chain as the Classic: `tools/root/chain.sh`
   with `Q20_IP` set to the P'9983's IP. The getroot `/q` helpers appear on
   the first boot after the flash, exactly as on the Classic.
5. **Optional**: run the persistence setup (v8.1 payload + three persisted
   jobs + the tree staging) — identical to the Classic flow documented in
   `docs/root-howto.md`.

## Notes

- The loader question is moot: bb10mt's loader DB and the Q10 autoloader's
  own 213-entry table both lack an 8F00270A entry (cap.exe would fall back
  to the default loader = the one bblink already uses). The real bug was
  the missing `libusb_set_configuration(1)` on reopen — fixed.
- If the device refuses the Q10 OS (model check in the loader's Complete
  validator), fall back to zeroing NV 0x2819/0x2852 via g_Disk_Drivers
  (docs section 23) — unlikely, the containers are stock.
- `probe_loaders.py` (tools/flash/) remains the tool for any future
  unknown-hwid device: it tests every candidate loader end-to-end.
