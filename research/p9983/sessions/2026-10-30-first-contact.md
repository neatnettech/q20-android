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
4. Repo: `research/p9983/` created; this note.
5. Autoloader parsed: the 10.3.3.498 builds prefix the ver2 header with a
   0x3C-byte table (the old check_autoloader.py only handled the Classic's
   unprefixed variant). Three containers, same shape as the Classic:
   `ifs.signed` (type 0x08, 167 blocks, 10.9 MB), `radio.signed` (type 0x0c,
   464 blocks, 30.5 MB), `os.signed` (0x09 RFS 6083 + 0x05 User 27613 blocks,
   2.2 GB). Extracted with the new `tools/flash/extract_autoloader.py`.
6. `tools/flash/flash_retry.sh` now takes the file list as args (defaults
   unchanged).

## Next steps

- [ ] Fresh-`0001` ritual on the P'9983 (unplug → brief power press → plug),
      then `flash_retry.sh ifs.signed os.signed radio.signed` (family 0x15,
      the Classic loader 9600270A — same MSM8960 bootrom).
- [ ] Boot, Dev Mode, `chain.sh` root.
