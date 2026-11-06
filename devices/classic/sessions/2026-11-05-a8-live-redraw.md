# A8 phase 1 - live redraw proven (2026-11-05)

The resident facade compositor works: the panel alternated between the real
Prober decor and a pushed solid-red frame under host control, at ~33ms poll
latency, with the Navigator retired.

## What was built

- `runtime/qnx-shims/facade_compositor.c`: `FACADE_WATCH=1` resident mode -
  after the initial post it polls `<frame>.seq` (content compare, not mtime;
  QNX stat granularity is too coarse) and re-posts on every change. One-shot
  mode unchanged.
- `runtime/art-qnx/src/graphics_facade.cc`: `Q20_DRAW_RAW` now writes
  tmp+rename (atomic) and bumps `<raw>.seq`. NOTE: the on-device libjavacore
  is still the pre-A8 build; the proof used manual seq bumps as root. The
  rebuild lands with the resident app loop (phase 2).
- The transport stayed files-on-/tmp (RAM-backed), not the planned
  shm+semaphore: tmp+rename gives atomicity, the seq file gives the precise
  change signal, and the poll costs nothing. Upgrade only if input latency
  demands it (ponytail note in the source).

## Device-access lessons (the expensive kind)

- **QNX OpenSSH 6.2 aes128-gcm is broken**: a modern client (OpenSSH 10.3)
  prefers gcm and the device sshd dies right after KEXINIT. Pin an explicit
  cipher list (never "+"). Wrappers: `tools/root/q20ssh-root` (root, 2225),
  `runtime/art-qnx/device/q20ssh` (devuser).
- **Devmode sshd (port 22) was down** despite dev mode on; started our own
  devuser sshd as root on **port 2222** (stock /usr/sbin/sshd, key auth,
  AuthorizedKeysFile=/accounts/devuser/.ssh/authorized_keys - the dir was
  EMPTY, key installed fresh). This instance is not persisted; it dies at
  reboot. Re-add to the payload if it proves useful long-term.
- Root sshd remote PATH is bare:
  `export PATH=/base/bin:/base/sbin:/base/usr/bin:/base/usr/sbin:/bin:/sbin:$PATH`

## A8 remaining (phase 2b - the app side)

- Rebuild libjavacore with the A8 transport + stage it (Docker make stage).
- Resident app loop: Launcher stays alive, redraws on invalidate, writes
  frame+seq each time (replaces the one-shot `facade draw`).
- The app polls `/tmp/frame.rgba.input` (lines `D|M|U x y`) + its `.seq`,
  dispatches MotionEvents into the View tree. Success = the Prober counter
  increments on touch.

## A8 phase 2a - input capture DONE (2026-11-06)

- Screen touch arrives as device-specific event types **100/101/102**
  (down/move/up) on the WM context, NOT the public SCREEN_EVENT_POINTER.
  `SCREEN_EVENT_NONE` (0) = poll idle (get_event returns success + empty
  event with timeout 0, no EAGAIN). Found empirically, verified by touch.
- `SCREEN_PROPERTY_SENSITIVITY=ALWAYS` set on the window.
- The input file is written DIRECTLY + seq-bumped after close: C `rename()`
  fails on /tmp here (32 silently lost publishes) while shell `mv` works.
  **TODO for the app-side frame writer: graphics_facade.cc's tmp+rename on
  /accounts/devuser has the same risk - fall back to direct write if the
  rename fails.**
- Verified: taps and swipes stream into /tmp/frame.rgba.input (D/M/U x y)
  with the .seq advancing.

## State left on device

The compositor (in the ls-oom-adj.sh carrier) is still resident holding the
panel; Navigator is retired. A clean reboot restores the BB UI and kills the
compositor (it is not persisted). The A7 compositor backup is at
/accounts/devuser/ls-oom-adj.sh.a7bak.
