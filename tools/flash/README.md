# tools/flash — Q20 (BlackBerry Classic) macOS flash lane

The macOS-native USB flash lane for the BlackBerry Classic (SQC100, MSM8960,
BB10/QNX). Replaces the Windows `cap.exe` autoloader path. Reverse-engineered
from bb10mt's binaries and the 9600270A RAM loader; proven on hardware
(2.2 GB OS+radio in ~5 min at 7.4 MB/s).

## Files

- `bblink.py` — raw USB link to the BootROM / RAM-loader (bootrom bring-up,
  password, loader upload, channel0/1/2, the `flash` verb). Requires `pyusb`
  (`pip install pyusb`); libusb via `brew install libusb`.
- `qcfm_unpack.py` — extract streams from an mfcq/.signed container.
- `flash_retry.sh` — flash with fresh-bootrom edge detection + retry (the
  robust one; auto-fires the instant a fresh `0001` appears).
- `flash_recovery.sh` — stock-rcfs recovery flash (no-seal path).
- `flash_radiofix.sh` — radio-only flash; cures the red-blink boot block.
- `flash_test.sh` — the seal-behavior test matrix (needs the t1..t4 containers).
- `resume_flash.py` — reuse an already-uploaded loader (8001) after an
  interrupted flash.
- `qrun.sh` — run a command file on the device via the getroot /q helpers
  (needs the door/ device-access tooling, which stays local).
- `loader_9600270A-00.bin` — the Classic's signed RAM loader (from cap.exe's
  table).

## The bootrom ritual (fresh 0001)

unplug USB → one brief power press → plug back in. A powered-off-with-cable
device lands in the resident loader (0x8001, ignores F7); only a fresh 0001
handshakes. A 0001 parked for minutes goes stale.

## Flash

```sh
# from the repo root; images live in ~/q20-flash/
python3 tools/flash/bblink.py --loader tools/flash/loader_9600270A-00.bin \
    --password <device-password> \
    flash OS.signed.unsigned radio.signed
```

Per-container seal control: `file.signed:none` (skip 40F9), `:dummy` (560 zero
bytes), `:seal=<file>` (explicit 560-byte install seal), default = the QNXH
trailer if present else zeros.

**Always end a session with a container that commits cleanly** (radio.signed
returns 4006). A session ending on a rejected `Complete` (402E) sets a global
no-boot flag = red blink; flashing radio clears it.

The OS `rcfs` stream never commits when modified (loader validator
`fcn.802046e4`: NV items 0x2819/0x2852 + TLV-0x85 payload struct; and
`rfs_validator` in the IFS rejects a modified rcfs at boot anyway). UFS/user
partition is ungated. See `docs/token-wall-and-device-access.md` sections 22-24.

## Tools added 2026-10-30/31 (P'9983 + general)

- `extract_autoloader.py <autoloader.exe> [outdir]` — extracts
  ifs/radio/os.signed; finds the ver2 header after a variable name table (0x30 to 0x3C, e.g. the 10.3.3.498
  builds prefix the ver2 header with a 0x3C-byte table).
- `probe_loaders.py <loaders-dir> [password]` — probes every candidate
  RAM-loader against a device end-to-end (upload → run → SetMode(2)); the
  winner is the one whose handshake answers. Use bb10mt
  (`bb10root/bb10mt` on GitHub, `autoloader loaders`) to extract a
  candidate set from an autoloader.
- `watch_flash.py [files...]` — 50ms bootrom edge watcher that fires the
  flash the instant a fresh 0001 appears (for devices with short bootrom
  windows).
- `flash_retry.sh` takes the file list as arguments (defaults unchanged).
- bblink now calls `libusb_set_configuration(1)` on reopen — REQUIRED for
  the Q10-family (8F00270A) bootrom, whose device comes up unconfigured
  when the RAM loader takes over (every loader appeared to hang at
  SetMode(2) without it).
