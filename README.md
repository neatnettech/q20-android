# q20-android

Android 6.0 on the BlackBerry Classic (Q20), which runs QNX.

## Status

| Item | State |
|---|---|
| Docker build environment (ubuntu:24.04 + PlayBook GCC 9.3) | done |
| Android 6.0.1 source downloaded (gitignored, local only) | done |
| Q20 runtime specimens and upstream research cloned (gitignored, local only) | done |
| Full Q20 Android 4.3 runtime extracted from signed BARs (gitignored, local only) | done |
| Android 4.3 vs 6.0 runtime comparison (docs/runtime-comparison.md) | done |
| ART 6.0.1 compiles and links for QNX armle (libart.so, zero unresolved) | done |
| dalvikvm built and executed on the Q20 | done |
| libjavacore built from libcore sources, native methods registered on-device | done |
| Marshmallow boot classpath extracted from the hammerhead factory image | done |
| Boot image (boot.art + boot.oat) loads on the Q20, GC heap initializes | done |
| Hello DEX execution | blocked on boot image build (dex2oat) |
| Q20 device SSH access | done (dev mode, re-enable after each reboot) |

## What blocks Hello World

The factory boot.oat contains compiled code with absolute pointers into the
hammerhead libart.so. Executed under our libart.so those pointers resolve to
NULL. A foreign boot image can never work; the boot image must be generated
by our own dex2oat so the addresses match our libart.so. Next build target:
`art/compiler` + `art/dex2oat` for QNX.

## Structure

* `art/` `bionic/` `libcore/` `frameworks/` `system/` AOSP 6.0.1 source
  snapshots (gitignored, downloaded, not committed)
* `Blackberry-Research/` upstream research reference (gitignored), see
  credits below
* `q20-runtime/` complete factory Android 4.3 runtime unpacked from the
  signed `sys.android` and `sys.android.shell` BARs for OS 10.3.3.3216
  (gitignored), see credits below
* `runtime/art-qnx/` the QNX port: compat headers, stub/replacement sources,
  build scaffold (`art-qnx.mk`), all recorded patches
* `runtime/patches/` recorded patches against the AOSP tree (gitignored
  sources; patches are the source of truth)
* `runtime/bootclasspath/` oat parser and extraction tooling (dex files
  themselves are gitignored artifacts)
* `runtime/hello/` the hello world DEX source
* `docs/` notes, specs, and findings
* `runtime/` ART, libcore, and dynamic linker (work area)
* `framework/` Android framework pieces (work area)
* `tests/` integration and unit tests
* `docker-compose.yml` Docker environment for AOSP build

## Credits

* Reverse engineering research on BB10/QNX and the factory Android runtime
  comes from stanw47's Blackberry-Research:
  https://github.com/stanw47/Blackberry-Research
  The extracted Q20 runtime specimens, binder on QNX port, graft layer, and
  session notes used by our analysis live in that repo (cloned locally as
  `Blackberry-Research/`, not committed here).
* The full Android runtime BARs (`sys.android-10.3.3.213`,
  `sys.android.shell-10.3.3.213`) come from ProjectBerry's BB10-Resources
  release "Fix/Update Android Runtime":
  https://github.com/ProjectBerry/BB10-Resources/releases/tag/runtime_v_update
  Extracted locally into `q20-runtime/` (not committed here).

## References

* https://github.com/acmiyaguchi/bbnix
  from-source cross-build userland for BlackBerry 10 / QNX 8 (armle-v7)
  expressed as Nix derivations; a ready made toolchain pipeline for our
  target ABI
* https://github.com/Psyden57/BB-PlayBook-gcc-9.3.0
  GCC 9.3.0 cross toolchain for BlackBerry PlayBook (QNX 6.5 armle-v7);
  the toolchain we use, via `toolchains/playbook-gcc9/`
* https://github.com/D-os/libbinder
  standalone build of android/platform/frameworks/native/libs/binder
  outside the AOSP tree; useful for building libbinder against QNX libc
* https://github.com/AsteroidOS/android_bionic
  bionic patched for libhybris compatibility; reference for building
  Android userspace on a foreign kernel/libc
* https://github.com/gentoobionic/bionic
  bionic built standalone with GCC (Gentoo); reference for porting bionic
  off Linux
* https://github.com/GrapheneOS/platform_bionic
  hardened bionic fork; source of post-6.0 fixes and hardening backports
* https://github.com/sw7ft/BerryCore
  continuation of Berry Much OS; BB10/QNX userland tooling and build
  knowledge
* https://github.com/BerryFarm/berrymuch
  power user Unix distribution for BlackBerry 10; running our own binaries
  on the Q20
* https://github.com/ZElfeheil/qvm-android-rpi4
  Android Automotive as a guest VM on the QNX 8 hypervisor; alternative
  architecture (virtualization instead of graft) and QNX-side integration
  patterns
