# Session 2026-11-06 — P'9983: the wizard skip, root caused (navigator autorun)

Question that opened the session: the Q20 (Classic) boots with no setup wizard
after a flash, so is the same available for the P'9983?

Answer: yes, and the 2026-11-01 attempt failed for a reason that is now
provable from the two images already on disk. No device needed, no download.

## What was compared

Unpacked both OS containers with `qcfm_unpack_streams.py` and walked both user
partitions with `qnx6_inspect.py`:

| Image | Build | UFS version |
|---|---|---|
| `~/q20-flash/OS.signed.unsigned` (the Classic's working bake) | SQC100 | `10.3.3.746` |
| `~/q20-flash/p9983/os.signed` (stock Q10) | Q10 "10.3.3.498" | `10.3.3.746` |

Both `/.rootfs.os.version` and `/.rootfs.pps.version` read `10.3.3.746`, the
`sig2` and `mbr` streams are md5-identical, and the two user partitions share
the same inode numbering throughout (34854 vs 34836 inodes walked). **The
build-sensitivity theory is dead**: the two user partitions are the same
template at the same version. Only the `rcfs` (the OS) hashes differ.

Full tree diff (path, inode, mode, size, uid:gid) over both partitions:

- Only in the Classic: the getroot bake (`/var/android/getroot/**`,
  `/var/pps/system/installer/upd/current/getroot`,
  `/accounts/devuser/rootdata/__root`), the ssh bits (`/root/.ssh/authorized_keys`,
  `/var/etc/ssh/sshd_config`), and `/var/pps/services/firstlaunch/status_public`.
- Only in the P'9983: nothing.
- Shared paths differing in content size: exactly one.

## The one file: /var/pps/system/navigator/config

```
classic (no wizard):   autorun::0
p9983  (wizard runs):  autorun::1
both:                  autorun_app::sys.firstlaunch.gYABgE1L_lY.sjW85E1SCBQsrco
```

The navigator launches `autorun_app` — the firstlaunch OOBE — at every boot
while `autorun` is 1. The Classic additionally carries the post-setup tutorial
state (`tutorials_app_launch_homeswipe_done:n:1`,
`tutorials_done_binary_code:n:63`, `tutorials_failed_homeswipe_done:n:1`,
`tutorials_setup_assistance_done:n:1`), which keeps the tutorial overlays off.

So `/var/pps/services/firstlaunch/status_public` (what `qnx6_wizskip.py`
injects) is not the gate. It is the wizard's own progress record; the navigator
never consults it for autorun. That is why the 2026-11-01 flash
(`os-wizskip.signed`, fsck clean, sig 4006 + Complete 402E) still booted into
the wizard. The UFS stream most likely landed exactly as documented; the marker
was simply the wrong one.

## The fix, built and verified

- New tool `tools/flash/qnx6_navautorun.py`: flips `autorun::1` to `autorun::0`
  and appends the four tutorials keys. The content stays inside one 4K block,
  so only the file bytes and the inode size field change — no bitmap, no free
  counts, no sb checksum (that covers `sb[8:512]` only). It re-reads the result
  through `qnx6_inspect.QNX6` and asserts before exiting.
- Applied to the UFS of `os-wizskip.signed` (so the firstlaunch flag stays,
  harmless), then spliced back into a copy of the container in place:
  **`~/q20-flash/p9983/os-navskip.signed`**. No repack was needed — the
  pfcq/rrcq records carry no payload CRC, so the header and the 560-byte
  `QNXH-OS-1` trailer are untouched by construction (the 2026-11-01 trailer
  lesson cannot bite here).

Verification done:

- The patched `/var/pps/system/navigator/config` is **byte-identical** to the
  Classic's (837 bytes).
- `/var/pps/services/firstlaunch/status_public` still present (ino 34838).
- Container layout re-read: same stream offsets, same size (2208433020),
  trailer still `QNXH-OS-`.
- `bb10mt qnx6 fsck -i` on the spliced UFS: **no errors found, clean**.

## Next: flash it

Device in a fresh bootrom `0001` (unplug, one brief power press, plug in):

```sh
python3 tools/flash/bblink.py --loader tools/flash/loader_8F00270A-00.bin \
    --password <device-password> \
    flash ~/q20-flash/p9983/ifs.signed \
          ~/q20-flash/p9983/os-navskip.signed \
          ~/q20-flash/p9983/radio.signed
```

Radio last so the session ends on a committing container (4006); the OS
container is still expected to answer Complete 402E (rcfs commit rejected, the
User stream lands). Success = the home screen, no enrollment step.

If the wizard still appears, the UFS stream is NOT landing on a 402E Complete
(the one assumption this session could not test offline), and the next probe is
the stock-flash-then-patched-flash order rather than another marker hunt.
