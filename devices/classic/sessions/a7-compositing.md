# A7 compositing - the breakthrough (2026-10-31/11-01)

The milestone: the app's first pixels on the Q20 display, driven by our own
presentation layer (not BB's app-launch path).

## The pipeline (all proven end-to-end)

1. **Draw** (devuser, in our ART runtime): `run_core.sh facade draw` with
   `Q20_DRAW_RAW=<file>` - the real Prober Activity rasterizes its View
   tree through our Canvas JNI (raster.cc) and writes a tightly packed
   720x720x4 RGBA frame (stride padding dropped).
2. **Post** (root): `facade_compositor <frame>` - claims the
   WINDOW_MANAGER context, creates its own window group, fills the window
   buffer stride-aware, posts.
3. The compositor also claims the **power-manager context** and sets
   `SCREEN_POWER_MODE_ON` - without it, retiring the Navigator black-screens
   the panel (the Navigator holds the power role too).

Deployment: the compositor is swapped into the trusted inode
(`/var/exfat/fs-exfat.so` is occupied by the sshd, so the carrier
`ls-oom-adj.sh` - also a trusted inode - holds it temporarily; back up the
payload first).

## The findings that shaped it

- Root grants every Screen context (devuser was EPERM on WM/DM/IP).
- Under a live Navigator, our window **blinks** - the Navigator's per-frame
  composition excludes unregistered windows, whatever the z-order.
- Killing the Navigator black-screens: it holds the power role; our
  compositor must claim it (`SCREEN_POWER_MANAGER_CONTEXT` +
  `SCREEN_PROPERTY_POWER_MODE=ON`).
- With the Navigator retired, our frame **stays** - the Prober's decor
  (count label + button) displayed on the panel.

## Next (A8)

The one-shot frame becomes a live loop: shared-memory framebuffer +
redraw signal (the compositor's comment already plans this), the
compositor stays resident, and Screen input events route into the
Activity. Then the facade is the device's UI.
