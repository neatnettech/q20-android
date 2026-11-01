# Session 2026-10-30 — first contact with the P'9983

## Facts collected

| Item | Value |
|---|---|
| Device | P'9983, model **SQM100-2** |
| Screen | `bb10-0015` |
| USB VID/PID | `0fca:8001` (RIM resident loader) — observed via `system_profiler` |
| SoC | MSM8960 (same as Classic SQC100) |
| Cross-flash candidate | `SQN100-1.Q10.BB10_3_3.10.3.3.498.exe` (archive.org, downloading) |

## Interpretation

`0fca:8001` means the bootrom/SBL chain is executing and exposing USB —
the device is not dead, it has no OS to boot (bb10-0015). On the Classic,
`8001` is the *resident-loader* state that ignores the F7 boot command;
only a fresh `0001` bootrom (the unplug → brief power press → plug ritual)
handshakes for a flash. Same ritual expected here.

## Sequence so far

1. 16:5x — user reports bb10-0015; device plugged in.
2. Probed USB: `0fca:8001` present (no `0001`).
3. Q10 10.3.3.498 autoloader downloaded (2.26 GB → `~/q20-flash/p9983/`,
   md5 `ec869d48...` = archive.org metadata match).
4. Repo: `devices/p9983/` created (was research/p9983); this note.
5. Autoloader parsed: the 10.3.3.498 builds prefix the ver2 header with a
   0x3C-byte table (the old check_autoloader.py only handled the Classic's
   unprefixed variant). Three containers, same shape as the Classic:
   `ifs.signed` (type 0x08, 167 blocks, 10.9 MB), `radio.signed` (type 0x0c,
   464 blocks, 30.5 MB), `os.signed` (0x09 RFS 6083 + 0x05 User 27613 blocks,
   2.2 GB). Extracted with the new `tools/flash/extract_autoloader.py`.
6. `tools/flash/flash_retry.sh` now takes the file list as args (defaults
   unchanged).

## Session 2026-10-30 (continued) — the loader saga

### The flash lane runs, then the RAM-loader handshake stalls

- Fresh 0001 edges caught several times (watcher @50ms poll). Bring-up gets to
  "RAM-loader online (PID 8001)" but `SetMode(2)` (channel0 cmd 7) **never
  answers** — with the Classic loader (9400270A) AND the Z10's (04002E07).
- bb10mt (`bb10root/bb10mt` on GitHub, Pascal, GPL) ships prebuilt
  `bb10mt_aarch64_darwin` + `loaders.dat` (5.6MB, "BB10MTR" archive, LZMA)
  + loose `loaders/*.bin`. Our tools/flash loader == bb10mt's
  `loader_9400270A-00.bin` == `LDR_00`, the generic/default 270A loader.
- bb10mt's `autoloader loaders` extracted 213 entries / 96 unique loaders
  from the Q10 exe. The Q10's own hwid (8F00270A) has **no** dedicated
  loader anywhere (not in bb10mt, not in cap.exe's table) — cap.exe would
  fall back to the default loader too. So the loader is NOT the problem.
- **The real bug: `libusb_set_configuration(1)`.** bb10mt's `TBBUSB.Open`
  always sets config 1 on reopen; bblink's `_open_pid` never did. On the
  8F bootrom the device comes up UNCONFIGURED when the loader takes over —
  writes land on a dead USB function, reads time out. Fixed in
  tools/flash/bblink.py.
- Model code corrected: 8F00270A = **SQK100-1** per bb10mt's BB10Devices
  table (8E00270A = SQK100-2); the P'9983 is the SQK100 family, not SQM100.
- Interrupted by a low battery: the device red-blinks, skips the bootrom
  window, and power-cycles (0001 for 0.1-11s) on USB power with no battery.
  Charging (30-60 min, battery in) restores a solid bootrom edge.

### Tools added

- `tools/flash/extract_autoloader.py` — extracts ifs/radio/os.signed from
  both autoloader header variants (the 10.3.3.498 builds prefix the ver2
  header with a 0x3C-byte table).
- `tools/flash/flash_retry.sh` — file list now passed as args.
- `tools/flash/bblink.py` — `set_configuration(1)` on reopen (the P'9983
  fix) + verbose step prints around the RAM-loader handshake.

### Pending

- [ ] Probe v3 (probe_loaders.py with the config fix) awaits a charged
      battery; then flash `ifs.signed os.signed radio.signed` (family 0x15,
      default loader) and boot.
- [ ] After boot: same root chain as the Classic (tools/root/chain.sh).

## Next steps

- [ ] Fresh-`0001` ritual on the P'9983 (unplug → brief power press → plug),
      then `flash_retry.sh ifs.signed os.signed radio.signed` (family 0x15,
      the Classic loader 9600270A — same MSM8960 bootrom).
- [ ] Boot, Dev Mode, `chain.sh` root.

## 2026-10-31: FLASHED - the Q10 loader was the answer

`loader_8700080A-00.bin` (bb10mt's LDR_67, the community's probed Q10-3
loader - byte-identical in the Q10 autoloader's own table) answers
SetMode(2) on the 8F00270A bootrom; the Classic's 9400270A loader (and
every other 8960-region loader probed) runs, enumerates USB, then hangs
mid-init. The earlier set_configuration(1) theory was wrong - the loader
is genuinely hwid-gated after USB init.

Full flash 2026-10-31: IFS 669 blocks + OS 134957 blocks (2.2 GB) + radio
1867 blocks, all three Complete 40C0 commits clean (stock containers,
ended on the radio). Device now boots the Q10 10.3.3.498 OS.

Loader kept at tools/flash/loaders/loader_8F00270A-00.bin (==
loader_8700080A-00.bin). probe_loaders.py (tools/flash/) was the tool that
found it: bb10mt's own probe never uploads anything - its validator just
rejects every loader for unknown hwids.
