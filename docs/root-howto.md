# Rooting the Q20 from macOS — the complete runbook

Proven 2026-10-30 on a BlackBerry Classic (SQC100, BB10 10.3.3.3216, MSM8960).
End state: `ssh -p 2225 root@<device>` is a real uid-0 shell. All steps run
from macOS; the only Windows-era tool left behind is cap.exe.

## Why this works (the model)

- The bootloader verifies the IFS (kernel); `rfs_validator` in the IFS
  accepts *unsigned* OS/radio images ("normal for non-signed builds"), but a
  modified rcfs can't reach the device anyway: the loader's Complete(40C0)
  commit gate (NV items 0x2819/0x2852 + a payload struct) rejects it, and
  even committed changes are rolled back. So root does NOT come from the
  rcfs. Only the UFS (user partition) flashes and boots unmodified.
- Pathtrust gates exec by **dev/ino**, not just path. Files we create
  anywhere (including our own mounts and new files in the Android dir) are
  untrusted for a root exec; the *existing* Android-subsystem inodes with
  overwritten content are trusted. That is Oleksandr's ls-oom-adj.sh trick.
- The switchzone `sz` installer job runs `/base/scripts/ota_info_pps.sh` as
  root. Redirect that path to a trusted inode and the payload runs as root.

## Prerequisites (once per machine)

- Python 3 with `pyusb`; libusb (`brew install libusb`).
- Device artifacts in `~/q20-flash/`: `OS.signed.unsigned` (the UFS-carrying
  OS container with the getroot package baked in), `radio.signed`, and the
  Classic RAM loader (also in `tools/flash/`).
- The local door tooling (`runtime/qnx-shims/door/`) for device SSH; the
  device's Dev-Mode password (default `drstone`).

## Step 0 — flash (needed once per root session)

Power off → unplug → **one brief power press → plug in** (the bootrom ritual;
a fresh `0fca:0001` appears). Then:

```sh
tools/flash/flash_retry.sh          # auto-fires on the fresh bootrom edge
```

~10 min. Boot the device normally, re-enable Development Mode + WiFi. This
first boot mounts `/q` (the getroot uid/gid helper set) — the helpers are
gone after any reboot, which is why this step repeats per session.

## Step 1 — the chain

```sh
Q20_IP=192.168.1.184 tools/root/chain.sh
```

It builds the QNX6 symlink image + the package locally, stages the payload
into the trusted carriers (`u_apps`), installs the shadow package via the
installer queue (`u_upd`), and fires `sz`. The switchzone **drops
dev-mode+SSH** each time (known, session 7o) — re-toggle Development Mode
afterwards to restore devuser access.

## Step 2 — root shell

```sh
ssh -p 2225 -i ~/.q20/id_rsa_q20 \
    -o StrictHostKeyChecking=no -o UserKnownHostsFile=$HOME/.q20/known_hosts_root \
    -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa \
    -o KexAlgorithms=+diffie-hellman-group14-sha1 -c aes128-ctr -m hmac-sha1 \
    root@192.168.1.184
```

The payload embeds the pubkey from `~/.q20/id_rsa_q20.pub`; edit
`tools/root/ota_info_pps.sh` if your key differs.

## Gotchas (all burned us once)

| Symptom | Cause | Fix |
|---|---|---|
| sz fails EACCES | payload 0644 in the qnx6 inode | mode 0x81ED (0755) |
| sz fails EPERM | payload at an untrusted dev/ino | symlink to an existing android-dir inode |
| sshd up, key denied | sshd_config lacks AuthorizedKeysFile (root $HOME != /root) | explicit `-o AuthorizedKeysFile=/root/.ssh/authorized_keys` |
| still denied | key file devuser-owned | StrictModes; write the key as root |
| red-blink after a flash | last session ended on a rejected Complete | flash radio.signed (clean commit) |
| bootrom stale | parked 0001 | ritual again; edge-detect in flash_retry.sh |

## Persistence (open)

Root, the shadow mount and the pathmgr symlinks are runtime-only — they die
at reboot. Re-root = Step 0 + Step 1 (~15 min). Boot-persistence candidates:
root-written `/var/pps` jobs (now writable as root) with a late-boot apply so
the `/base/scripts` shadow doesn't hide `startup.sh` mid-flight; or the
boot0-write path (session 7t + 7o: as root, patch the sdmmc driver's
partition-attached flag via `/proc/<pid>/as`, clear `B_PWR_WP_EN`, write
`bbss.insecure` at boot0 `0x35a98`). See
`docs/token-wall-and-device-access.md` sections 22-26 for the full history.
