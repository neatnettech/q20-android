# A9 session 2: the AOSP Calculator live on the Classic (2026-11-06)

NOD-9 session 2. The unmodified AOSP 6.0.1 Calculator (`android-6.0.1_r81`)
runs on the panel under our ART: real touch dispatch, its own click handlers,
its arity evaluator, its result animation, CLR and DEL.

## How it is built and run

* Source: `packages/apps/Calculator` (gitignored, AOSP layout), cloned at
  `android-6.0.1_r81`. `apps/calculator/build.sh` builds `calculator.apk` with
  aapt2, javac and d8, adding `arity-2.1.2.jar` and support v4 23.1.1 (from
  Google Maven, kept in `toolchains/android-tools/support/`). Unsigned.
* `run_core.sh` runs any app: `APP_APK` and `APP_ACT` pick it (the Prober by
  default) for `facade`, `tap` and `live`.
* Headless check: `sh run_core.sh tap digit_1 op_add digit_2 eq formula=3`
  taps views by id through the real dispatch path and checks `id=text`.
* Panel: `( sh run_core.sh live > out/live-runner.log 2>&1 & )`, launched
  detached (see the A8 note on session children). `sh run_core.sh snap`
  copies the last frame to `out/frame.rgba` for a host side PNG.

## What the Calculator needed

In the order the traces asked for it:

* Launcher: the manifest theme; a real `View.AttachInfo` (main looper Handler,
  so `View.post` runs) with a `ViewRootImpl` that is constructed but never
  `setView()`'d (ViewPager's `postOnAnimation` needs its Choreographer); a
  Looper driven tick that lays out when `isLayoutRequested()` and draws when
  `isDirty()`; touches as real `MotionEvent`s into `dispatchTouchEvent`.
* Fake services: `package` (every EditText's Editor needs a PackageManager),
  `textservices`, `input_method`, `accessibility` (missing, it was looked up
  642 times per tap run).
* libjavacore natives: MotionEvent and VelocityTracker (stock JNI over
  libinput `Input.cpp` and `VelocityTracker.cpp`, patch 0104 drops Skia and
  parcels), AndroidBidi (the minus key is U+2212), StringToReal and
  RealToString (`Double.parseDouble`, patch 0105 for an ambiguous `pow`).
* Graphics facade: `Canvas.drawCircle` (ripples; raster engine plus a host
  test), Region (bounding rect), `Paint.getTextBounds` (FreeType ink boxes),
  PorterDuff Xfermode handles (EdgeEffect), `Matrix.mapRect`, the RenderNode
  transform matrix and `Canvas.concat` (translation only), and RenderNodeAnimator
  finishing on start (the circular reveal before CLR clears).
* Calibration knob `q20.facade.orientation=landscape` in `device/build.prop`:
  WindowManager calls a square panel portrait, but the phone portrait layout
  clips every label at 360x360 dp; the app's landscape layout fits, with all
  three pads visible.
* Input: the compositor replaces its input file per batch, so a quick tap's
  down could be lost between two polls. The launcher now replays a missing
  down before an orphan up or move.

## Results

Headless (`run_core.sh tap`, AOT against the rebuilt boot13 image):

| Sequence | Result |
|---|---|
| `1 + 2 =` | formula `3` |
| then `CLR` | formula empty |
| then `7 × 6 =` | formula `42` |
| `9 − 4`, `DEL`, `5 =` | `9−4`, `9−`, `4` |
| Prober `bump_button` | `count: 1` |

`facade gfx` 9/9 in both modes. On the panel: the full landscape layout, live,
confirmed by photo.

## Lessons

* One ART at a time: a second dalvikvm next to the live one fails its fixed
  address heap reservation (`Failed anonymous mmap ... Not enough memory`).
* A `q20put` dropped by Wi-Fi leaves the remote `cat` holding the file open
  for writing; `dlopen` of that library then fails with "Library cannot be
  found". Kill the stale session (`pidin -f anu`, look for `bin/cat`).
* boot13 rebuilt on the device in about 14 minutes (NOD-25); with it, the
  Calculator AOT compiles in 6 s.

## Known gaps

* Pad labels like DEL, cos and tan still wrap per letter: those cells are
  narrower than the word at this size, as on a real phone of this shape.
* No reveal motion (the overlay just flashes) and no scale while the result
  animates (translation only).
* The Prober's Material button ripple masks with a Bitmap when drawn while
  pressed (Bitmap natives absent); not exercised in this session.
