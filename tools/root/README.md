# tools/root — the Q20 runtime root chain

The macOS-only chain that produced real uid-0 on the Classic (see
`docs/token-wall-and-device-access.md` section 26). Runs entirely at runtime
after one UFS flash; no rcfs/boot modification (rfs_validator + the loader
commit gate make that a dead end).

## Chain (all scripted in `chain.sh`)

1. **UFS flash** (tools/flash/) — first boot after it mounts `/q` (the getroot
   uid/gid helper set). Required once per root session.
2. **`qnx6symlink.py`** builds `pop.qnx6`: a QNX6 image (host-written; the
   on-disk layout was decoded empirically — see the header) whose only files
   are *symlinks*: `ota_info_pps.sh` and `migration_logging.sh` → the Android
   subsystem's scripts. Those are trusted dev/ino (pathtrust is per-inode);
   their *content* is our payload, staged via the `u_apps` helper.
3. **`makepkg.py`** wraps it as a device-configuration package:
   `mount:assets/data/pop.qnx6:/base/scripts:qnx6`. Install via the `u_upd`
   installer queue (andrB → no signature checks).
4. **sz job** (`action::switchzone session::1`) via `u_upd` → deckard runs
   `/base/scripts/ota_info_pps.sh` **as root** → the symlink resolves to the
   trusted carrier → the payload executes as root.
5. **Payload** writes our pubkey to `/root/.ssh/authorized_keys` and starts
   `sshd` on 2225 with explicit flags (StrictModes was the last gotcha).

`ssh -p 2225 root@<device>` = uid-0.

## Gotchas that cost us iterations

- 0644 payload → EACCES on exec (need 0755 in the qnx6 inode).
- Payload *inside* our mounted fs → pathtrust EPERM (untrusted dev/ino) —
  must resolve to an existing Android-subsystem inode.
- `sshd_config` lacked `AuthorizedKeysFile` (root's `$HOME` isn't `/root`).
- Door-pushed key file is devuser-owned → StrictModes denial for root login.

## Persistence (open)

Root lasts until reboot (shadow mount + symlinks + sshd are runtime-only).
Re-root = flash + `chain.sh`. A boot-time variant is possible in principle
(root can now write `/var/pps` jobs) but shadowing `/base/scripts` during
boot risks hiding `startup.sh`'s siblings mid-boot — needs an ordering
experiment.
