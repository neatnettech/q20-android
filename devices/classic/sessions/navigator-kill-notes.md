# Retiring the Navigator - kiosk mode + the recovery gotcha

For the A7 kiosk experiment, the Navigator (the BB10 window manager,
`/apps/.../app/navigator`, also the display's power holder) is retired:

- `slay -f <navigator-pid>` (find via `pidin | grep app/navigator`).
- Run the facade_compositor with `FACADE_WM=1` - it claims the WM and
  power-manager roles and the frame stays on the panel.
- The BB10 UI is gone while it runs: the device is our kiosk.

## Gotchas

- **Crash-loop protection**: after the Navigator was killed, the next boot
  can come up with NO Navigator (black, unresponsive UI - the launcher
  supervisor refuses to respawn it). A **clean reboot restores it**
  (it starts normally on a fresh boot). Always reboot cleanly after the
  kiosk experiment.
- **The trusted-inode juggling**: the compositor shares the trusted-inode
  channel with the payload and the sshd - always back up whatever the
  inode/carrier holds before the swap (`/tmp` backups die at reboot).
- The frame file (`/tmp/frame.rgba`) is RAM-backed: re-copy from
  `/accounts/devuser/frame.rgba` after any reboot.
