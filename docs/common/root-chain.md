# The runtime root chain

Root uid-0 at runtime, without touching the rcfs (which `rfs_validator` +
the loader's commit gate make a dead end). Tooling: [tools/root/](../../tools/root/).

## The model

1. **Pathtrust trusts by dev/ino.** Files we create anywhere (including our
   own mounts) are untrusted for a privileged exec; the *existing* Android
   subsystem inodes with overwritten *content* are trusted (Oleksandr's
   ls-oom-adj.sh trick). The trust list lives in `/base/etc/rootfs.trusted`
   and is locked down at boot (`/proc/boot/pathtrust.sh`).
2. **The switchzone `sz` job runs `/base/scripts/ota_info_pps.sh` as root**
   (session::0 early boot, session::1 later - the active session races).
3. So: a host-built QNX6 image whose entries are *symlinks* to the trusted
   carriers, mounted over `/base/scripts` by a deviceconfig package, turns
   the sz into a root payload trigger.

## The chain (chain.sh)

qnx6symlink.py (the image) -> makepkg.py (the deviceconfig BAR) -> stage
the payload into the carriers via the /q helpers -> install the package via
the installer queue -> fire the sz -> payload runs as root.

`/q` (the getroot helper set) exists only on the first boot after a UFS
flash; any reboot kills it.

## Persistence (v8.1, self-healing, verified over reboots)

Three persisted installer jobs (the pps store under
`/var/pps/system@0.0.775/installer@88.88.755/upd@88.88.755/current@88.88.2775`,
files named `job.X@0.88.664` - uid 0, gid 88, persist attrs) fire at every
boot: the install job (mount), then sz session::0 and ::1 (one wins).
deckard consumes switchzone jobs at fire time and re-consumes same-boot
re-writes, so the payload re-arms all three from a detached
`sh -c 'sleep 90; ...'` helper (inline - untrusted script files hit the
exec gate).

The payload also rebuilds the deckard unpack tree (deckard deletes it on
every install) and starts the kill-proof sshd (below). Root SSH: port 2225.

## The carrier map (hard rules - the 2026-11-06 break)

| Path in `native/scripts/` | Holds | Rule |
|---|---|---|
| `ls-oom-adj.sh` | payload v8.1 (via the ota_info_pps.sh symlink) | NEVER clobber |
| `ps-android-apps.sh` | migration payload (via migration_logging.sh) | NEVER clobber |
| `restore-cleanup.sh` | the facade compositor (A8) | the dedicated experiment slot |

The self-healing is ONE BOOT DEEP: the payload must run every boot to re-arm
the jobs; if a boot runs something else from the carrier, deckard consumes
the jobs and the chain is gone for good (full story:
devices/classic/sessions/2026-11-06-chain-break-and-recovery.md).

Gotchas that each cost an iteration: 0644 payload (exec EACCES), payload
in our own mount (untrusted dev/ino EPERM), missing AuthorizedKeysFile
(root's $HOME is not /root), devuser-owned key file (StrictModes).
