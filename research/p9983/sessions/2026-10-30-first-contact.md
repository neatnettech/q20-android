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
3. Q10 10.3.3.498 autoloader download started (2.26 GB → `~/q20-flash/p9983/`).
4. Repo: `research/p9983/` created; this note.

## Next steps

- [ ] Fresh-`0001` ritual on the P'9983 (unplug → brief power press → plug),
      confirm `0fca:0001`.
- [ ] Extract OS/radio from the autoloader (`qcfm_unpack.py`).
- [ ] `bblink.py flash` OS → radio (family 0x15).
- [ ] Boot, Dev Mode, `chain.sh` root.
