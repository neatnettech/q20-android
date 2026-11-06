# Chain break + full recovery (2026-11-06) - root restored

## What broke

On 2026-11-05 I deployed the A8 compositor into `ls-oom-adj.sh` - which is
the LIVE PAYLOAD carrier (`/base/scripts/ota_info_pps.sh` symlinks to it via
the qnx6 mount, and the sz job runs that path as root). A boot later: the sz
fired, the shell tried to parse an ELF as a script, the payload died, deckard
consumed the persisted jobs, and the chain went inert (no mount, no sshd).
The self-healing is **one boot deep**: the payload must run every boot to
re-arm; one dead boot kills the chain permanently.

Root causes: (1) no dedicated compositor slot, (2) the carrier content was
assumed from size only (`head`/`od` absent on device), (3) the A7-era notes
said "back up whatever it replaces" but the restored state was never verified
post-experiment.

## Recovery path (proven end-to-end)

1. **No Wi-Fi path exists**: sshd 2225 dead, devmode 22 needs the door, the
   door daemon silently drops Wi-Fi peers (wired-connection check), SMB is
   media-only. Everything funnels through the USB door.
2. **USB battles on the Mac**: the Q20's USB iface is 169.254.0.1/30 and
   only talks to 169.254.0.2; macOS self-assigns a /16 the device ignores,
   re-does it on every reseat, and the gadget carrier flaps (device sleep
   drops it). Fix: `tools/flash/q20usb-net.sh` (sudo; pins the /30 and
   bounces dead interfaces).
3. **Door (user mode) over USB** brings up the devmode sshd on **22 on ALL
   interfaces** - but the authorized_keys came from the door push, and the
   post-flash sshd re-keyed, so `~/.q20/known_hosts*` stale entries block
   auth (StrictHostKeyChecking=no accepts new keys, NOT changed ones).
4. **Reflash** (bootrom ritual -> flash_retry.sh with
   `~/q20-flash/OS.signed.unsigned ~/q20-flash/radio.signed`; the images live
   on the WD500 offload drive - `~/q20-flash` is a symlink to it). First boot
   mounts `/q`.
5. **chain.sh over USB** (`Q20_IP=169.254.0.1`; qrun.sh now honors Q20_IP;
   the Wi-Fi sshd had rejected the key while USB accepted it). One transient
   `u_upd` failure mid-chain - re-running the single step manually was enough
   (the cp then reported rc=0).
6. sz fired -> payload v8.1 ran -> sshd on 2225 (kill-proof, as
   /exfat/fs-exfat.so) -> persisted jobs re-armed. Verified.

## The fixes that make this the last time

- **Dedicated compositor slot**: `restore-cleanup.sh` (trusted, dormant -
  only runs during a factory restore we will never do). Verified exec as
  root. The carrier map is now hard rules:
  - `ls-oom-adj.sh` = payload v8.1 - NEVER clobber
  - `ps-android-apps.sh` = migration payload - NEVER clobber
  - `restore-cleanup.sh` = facade compositor
  - `/var/exfat/fs-exfat.so` = sshd
- `tools/flash/q20usb-net.sh` + `sudo -v && sudo sh ... &` (backgrounded sudo
  cannot read the tty password prompt - `sudo -v` first).
- `q20ssh-root` now has StrictHostKeyChecking=accept-new; re-key after every
  reflash: clear `~/.q20/known_hosts*`.
- qrun.sh: `${Q20_IP:-192.168.1.184}` everywhere (both copies).
