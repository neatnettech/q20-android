# Target: the Prober APK, and the ladder to it

The next real goal is one concrete artifact: **an APK built by us that runs on
the Q20 and exercises every assumption the platform depends on**. Everything
in this file is scoped to that. Full system_server and a launcher stay a
separate, later effort.

## The app: Q20 Prober

Package `dev.q20.prober`, minSdk 23, plain Java (no support libraries), built
with javac + d8 + aapt2 on the host. One Activity, deliberately boring:

* A label showing a counter (text rendering, layout, resources)
* A button that increments it (input, dispatch, invalidation, redraw)
* Lifecycle logging: onCreate/onStart/onResume/onPause printed to stderr
* A second screen with a list (adapter views, scrolling, more input)
* An image drawn on screen (graphics path beyond text)
* A short audio beep on tap (audio)
* Writes a line to its app data dir (storage/sandbox)

The crucial design decision: **the app has two entry points**.

1. `main(String[])` runs a headless self test that exercises the same code
   paths without a window: framework classes, ICU, regex, resources, layout
   measurement. Every milestone up to the window one can run headless first.
2. The normal Activity entry, which starts mattering once a window exists.

That way the ladder below de-risks assumptions in order, and each step has a
cheap headless check before it needs the display.

## Assumption map

| Assumption | Killed by |
|---|---|
| APK parsed and classes.dex loaded on QNX (zip + FileMap) | A2, A3 |
| Our verifier accepts our own dex, quickened or not | A3 |
| App dex runs AOT (dex2oat reads the APK) and interpreted | A3 |
| An unsigned QNX process can own a screen | A4 |
| libandroid_runtime JNI registers and runs on QNX | A5 |
| libcore regex natives (deferred so far) work; ICU classes run | A5 |
| AssetManager reads our resources.arsc, getString works | A6 |
| Looper/Handler message pump works on QNX (libcore poll path) | A6 |
| Activity lifecycle + View measure/layout without a window | A6 |
| Graphics: our pixels reach the Q20 screen (EGL or direct Screen) | A7 |
| Touch and key events reach a window and dispatch | A8 |
| Audio output works | A9 |
| App data dir + storage writes work | A9 |
| The app runs in its own process (no zygote yet) | A10 |

## Milestones

| ID | Goal | Exit criteria |
|---|---|---|
| A1 | Host tooling | aapt2 + javac + d8 produce q20prober.apk with classes.dex, resources.arsc, manifest |
| A2 | Real libziparchive | system/core libziparchive + FileMap built into the runtime; dex2oat reads classes.dex out of the APK on device |
| A3 | Headless app | `dalvikvm -cp q20prober.apk Q20Prober` runs main() self test, prints, exits 0; AOT via a dex2oat pass over the APK as well |
| A4 | Screen probe | an unsigned process can (or cannot) create a QNX Screen window and get a surface to draw into; result decides A7's route |
| A5 | Framework slice | app uses android.util.Log, android.os.Bundle/SystemClock, java.util.regex, android.icu.text.PluralRules for real; libandroid_runtime subset + regex natives land |
| A6 | Activity headless | Activity.onCreate runs against a minimal context, resources resolve via AssetManager, a View tree measures and lays out; no window yet |
| A7 | Window | the app's first pixels on the Q20 display, driven by A4's route |
| A8 | Input | button tap increments the counter: touch, key events, dispatch, invalidation, redraw |
| A9 | Full app | second screen list, image draw, audio beep, file write; lifecycle survives pause/resume |
| A10 | Process model | the app runs in its own process with its own data dir and UID (no-zygote preload or mmap_peer ashmem route, per docs) |

## Risks, in order of scariness

1. **Graphics (A7)**: the Q20 GPU stack under QNX is the biggest unknown. The
   factory runtime shipped its own EGL layer, so it is possible, but expect
   archaeology. If direct Screen software rendering is viable, use it first
   and optimize later.
2. **Framework natives (A5/A6)**: libandroid_runtime is huge; only the parts
   the app touches get ported, but a real Activity touches a long tail.
3. **Input (A8)**: Screen events exist, but the bridge into the framework
   InputDispatcher is unproven.
4. **Audio (A9)**: QNX audio via resource manager, needs a libmedia path.

The cheap stuff (A1 through A4) is days. A5/A6 are the iterative long tail.
A7 is the gate that tells us whether this becomes a sprint or an expedition.

## How the runtime changes vs the framework

Nothing in A1 to A6 needs zygote, binder, or system services. The app runs
under dalvikvm directly, Activity machinery included, with no
ActivityManager: our own bootstrap calls ActivityThread-ish entry points
directly. That is the point: measure how much of Android is actually
reachable without system_server before deciding whether system_server is
worth building.
