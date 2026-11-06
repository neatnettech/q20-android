# BlackBerry Classic (SQC100) - rooted development device

- **hwid** 9600270A, MSM8960, BB10 10.3.3.3216. IP 192.168.1.184.
- **Root**: persistent uid-0, self-healing across reboots. `ssh -p 2225
  root@192.168.1.184` (the kill-proof sshd in the trusted inode). The
  technique: [../../docs/common/root-chain.md](../../docs/common/root-chain.md).
- **A8 compositing: DONE** - the live facade: the Prober's real View tree
  renders on the panel and responds to touch (the counter increments on
  button taps, exactly +1). The full loop: Screen touch -> root compositor
  -> input file -> Launcher dispatch -> redraw -> frame -> panel. See
  [sessions/a7-compositing.md](sessions/a7-compositing.md) and
  [sessions/2026-11-05-a8-live-redraw.md](sessions/2026-11-05-a8-live-redraw.md).
- **Next**: A9 - the first real app port (closing the StaticLayout/NativeConverter
  native gaps found by A8), and NOD-11 - the facade as the default UI.

## Sessions

- [sessions/2026-11-06-chain-break-and-recovery.md](sessions/2026-11-06-chain-break-and-recovery.md) -
  the chain break, the reflash recovery, and the carrier-slot discipline that
  prevents a repeat.
- [sessions/2026-11-05-phone-home-inventory.md](sessions/2026-11-05-phone-home-inventory.md) -
  NOD-15 part 1: live recon, the kill list, the Akamai sighting.
- [sessions/a7-compositing.md](sessions/a7-compositing.md) - the A7
  breakthrough and the presentation-layer model.
- [sessions/navigator-kill-notes.md](sessions/navigator-kill-notes.md) -
  retiring the Navigator for the kiosk mode, and the recovery gotcha.

## History

The full investigation lives in
[../../docs/token-wall-and-device-access.md](../../docs/token-wall-and-device-access.md)
(sections 1-27) and [../../docs/apk-milestones.md](../../docs/apk-milestones.md)
(the A ladder).
