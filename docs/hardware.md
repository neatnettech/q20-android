# Q20 hardware inventory

From teardown photos of a BlackBerry Classic (Q20), OCR'd
(`internals/IMG_3937..3941.HEIC`, not committed).

## Main motherboard

* Manufacturer: AT&S
* Board model: `SBOCLS1B05I` (CLS = Classic)
* PCB material: MX3 SH, UL 94V-0
* Date code: week 30 2015 (`3015`), unit built Oct 2015 (`20-10-15`)
* Carries Qualcomm MSM8960 (Snapdragon S4 Plus), 2 GB RAM, 16 GB flash
  (per Q20 spec, not visible in photos)

## Keyboard / toolbelt

* Keyboard PCB: `CB-46495-002_1`
* Flex assembly: `FKM002A-0226-02 Rev A`
* Controller chip on keyboard PCB: `MFC3 3415` (capacitive key/trackpad)
* Flex cable: `FC 1521 2-1`, connector marking `5L-01-02`

## Device identity

* Made in China (unit built Oct 2015)
* IMEI and BlackBerry PIN recorded privately, not in this public repo

## Notes

* Not photographed: battery, LCD, camera module. Those sit above this
  stack; all remain QNX-owned in the graft approach, so no driver work
  depends on this inventory.
* Board revision could matter later for radio/NFC variant config; tracked
  here for reference.
