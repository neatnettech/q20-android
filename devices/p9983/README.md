# P'9983 (Porsche Design Q10) — research & recovery

**ROOTED 2026-11-06**: `ssh -p 2225 root@192.168.1.185` = uid-0, with the
same self-healing boot persistence as the Classic. Second target of the
two-devices-one-chain setup.

## Sessions

- [session-2026-10-30-first-contact.md](sessions/2026-10-30-first-contact.md) — first probe, USB state, plan.
- [session-2026-10-31-resume-plan.md](sessions/2026-10-31-resume-plan.md) — the resume plan after charging.
- [session-2026-11-01-image-swap-plan.md](sessions/2026-11-01-image-swap-plan.md) — image-swap ruled out; enrollment reframe; the QNX6 wizard-skip injection (tools + flash lesson + the flag not working on the Q10 build).
- [session-2026-11-06-oobe-autorun-root-cause.md](sessions/2026-11-06-oobe-autorun-root-cause.md) — the navigator autorun root cause + the navskip image.
- [session-2026-11-06-rooted.md](sessions/2026-11-06-rooted.md) — **ROOTED**: the /q getroot bake, the timestamp-overflow fix, the session-0 sz, persistence.
- [session-2026-11-06-oobe-autorun-root-cause.md](sessions/2026-11-06-oobe-autorun-root-cause.md) — the wizard skip root caused: navigator `autorun::0`, not the firstlaunch flag; patched container built + fsck clean.

## The hardware case

- Model: **SQK100-1** (8F00270A) (Porsche Design Q10). Hardware-identical to the Q10
  (**SQN100-1..5** + **SQK100-1/2**): MSM8960 SoC, 3.1" 720×720 AMOLED, 35-key QWERTY.
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

- [x] ~~Does the loader's `Complete` validator (NV 0x2819/0x2852 + TLV-0x85
      struct) check the device *model*?~~ **Resolved 2026-11-01**: the SQK100
      autoloaders that exist (archive.org: 10.3.1.997, 10.3.2.159 only) are
      byte-identical in payload to the SQN100 (Q10) builds of the same
      version — verified with HTTP Range slices: same PE stub, same
      containers, only a 4-byte difference in a scrambled name table.
      CrackBerry owners confirm: the P'9983's official 10.3.3 autoloaders
      (2205/3216) are "totally the same" as the Q10 ones; the PD clock/theme
      was an add-on, not a different OS. So the Q10 10.3.3.498 build we
      flashed IS the P'9983 image, and the first-boot hang is not a
      model/variant rejection.
- [ ] Does the P'9983 theme survive a Q10 flash? **Resolved 2026-11-01**: no —
      CrackBerry owners report losing the PD clock/theme on 10.3.3; it was
      an add-on, not baked into the SQK100 OS variant (which is byte-identical
      to the Q10 build anyway).
- [ ] Root persistence work (boot0 writes, session 7t) applies identically —
      two devices = two targets, one chain.
