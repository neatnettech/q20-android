# P'9983 (Porsche Design Q10) — research & recovery

Second device on the bench: a **P'9983** (Porsche Design variant of the Q10).
It currently boots to **`bb10-0015`** — the bootloader found no bootable OS.

## The hardware case

- Model: **SQM100-2** (Porsche Design Q10). Hardware-identical to the Q10
  (**SQN100-1/2/3**): MSM8960 SoC, 3.1" 720×720 AMOLED, 35-key QWERTY.
- Same platform generation as the Classic (SQC100) we rooted 2026-10-30 —
  same PBL bootrom, same bb10mt flash protocol, same macOS flash lane
  (`tools/flash/bblink.py`), same runtime root chain (`tools/root/chain.sh`).
- The only differences from a Q10 are cosmetic (Porsche Design theme in the
  OS variant build) — flashing a Q10 OS build should boot fine and may drop
  the PD skin.

## State as observed (2026-10-30)

- Screen: `bb10-0015` (no bootable OS — the SBL chain came up, the OS did
  not; same error class as the Classic's red-blink state, i.e. a software
  condition, recoverable).
- USB enumerates as **`0fca:8001`** (RIM vendor, resident-loader product id)
  — bootrom chain is alive, hardware good.

## Recovery plan

1. Download the Q10 autoloader
   (`blackberry10-autoloaders` on archive.org →
   `SQN100-1.Q10.BB10_3_3.10.3.3.498.exe`, 2.26 GB) — running now into
   `~/q20-flash/p9983/`.
2. Extract `OS.signed` + `radio.signed` with `tools/flash/qcfm_unpack.py`
   (same mfcq/cap.exe format as the Classic autoloader).
3. Flash both via `tools/flash/bblink.py flash`, family byte **0x15**
   (the 8960 generation; Classic used 0x15, Passport 8974 uses 0x40).
   OS first, radio last (never end a session on a rejected `Complete`,
   or the device red-blinks — see tools/flash/README.md).
4. Boot → set up Development Mode + WiFi → run the same root chain
   (`tools/root/chain.sh`); the stock OS flash brings the `/q` getroot
   helper set on first boot, exactly as on the Classic.

## Open questions

- [ ] Does the loader's `Complete` validator (NV 0x2819/0x2852 + TLV-0x85
      struct) check the device *model*? If a Q10 build is refused, the
      fallbacks are: an actual SQM100 autoloader (none in the archive.org
      item), or zeroing the NV items via `g_Disk_Drivers` (we have the RE,
      docs/token-wall-and-device-access.md section 23).
- [ ] Does the P'9983 theme survive a Q10 flash? (Expected: no — it becomes
      a Q10 in software. The PD skin may be restorable from an SQM100 dump
      if one surfaces.)
- [ ] Root persistence work (boot0 writes, session 7t) applies identically —
      two devices = two targets, one chain.

## Sessions

- [session-2026-10-30-first-contact.md](sessions/2026-10-30-first-contact.md) — first probe, USB state, plan.
