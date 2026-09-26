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
| dex2oat built and running on the Q20, hello.dex compiled to hello.oat on-device | done |
| Boot image build from the 13 extracted dex files | in progress (GC marks a zeroed object at main space + 0xf90, see docs/bringup-log.md) |
| Hello DEX execution | blocked on boot image build |
| Q20 device SSH access | done (dev mode, re-enable after each reboot) |

## What blocks Hello World

The factory boot.oat contains compiled code with absolute pointers into the
hammerhead libart.so. Executed under our libart.so those pointers resolve to
NULL. A foreign boot image can never work; the boot image must be generated
by our own dex2oat so the addresses match our libart.so. Next build target:
`art/compiler` + `art/dex2oat` for QNX.

## Timeline

### Phase 0: ART runtime (done)

* ART 6.0.1 builds, links, and runs on QNX armle
* `libjavacore` built from libcore sources, native methods register on-device
* Marshmallow boot classpath extracted (13 dex files) from the hammerhead
  factory image
* Boot image loads on the Q20, GC heap initializes
* `FUTEX_CMP_REQUEUE` shim implemented and tested on-device (runtime uses
  pthread mutexes via `ART_USE_FUTEXES=0`, so futex is not the live path)

### Phase 1: dex2oat and the Quick ARM compiler (current)

* `dex2oat` builds and runs on the Q20: hello.dex compiled to hello.oat
  on-device
* Quickened factory dex accepted by the verifier and compiler (patch 0040),
  boot image build is deep into framework compilation
* Blocked: SIGSEGV in the compile phase, GC marking an object with a null
  class pointer (details in docs/bringup-log.md)

The compiler chain is the critical engineering frontier. Scope for 6.0.1
arm32 is the Quick backend only; the optimizing compiler is off by default
and VIXL is arm64 only.

1. Build compiler infrastructure: `art/compiler` (driver, oat_writer,
   image_writer, elf_writer, dex layout)
2. Build the ARM Quick backend: `compiler/dex/quick/arm`
3. Build a real `libziparchive` from `system/core` plus FileMap (our current
   zip stubs return failure, and dex2oat must read dex containers)
4. Get the `dex2oat` executable running on the Q20 (done, on-device
   hello.dex -> hello.oat works)
5. Compile one small dex plus the boot dex files in a single dex2oat
   invocation (done as the full boot image build now)
6. Execute the AOT compiled hello.oat under ART
7. Full boot image build from the quickened factory dex (in progress)

The single dex step turns the problem into `hello.dex -> dex2oat -> Quick
ARM -> hello.oat -> ART -> Hello World` instead of debugging a giant boot
image failure over hundreds of classes.

### Phase 2: platform formalization

Stabilize `runtime/art-qnx/` into a platform contract rather than a
collection of build fixes:

```text
runtime/art-qnx/
    ├── compiler/
    ├── runtime/
    ├── libjavacore/
    ├── qnx-shims/
    └── patches/
```

The compat layer becomes the formal QNX platform abstraction that later
Android versions would also target.

### Phase 3: process model and zygote

Before calling zygote done, resolve how processes share runtime state:

* Path A (long term): proper QNX ashmem via `mmap_peer` (QNX peer mapped
  memory). POSIX `shm_open` fails on BB10, there is no `/dev/shmem` server;
  the factory runtime used `mmap_peer` / `mem_offset64_peer` for exactly
  this. The current unlinked temp file does not survive fork sharing.
* Path B (factory style): skip fork based zygote and preload each app
  process independently, like the factory runtime did.

Path B unblocks APK execution fastest; Path A stays the long term target.

### Phase 4: security baseline

The security milestone is empirical, not architectural:

> Can an unprivileged APK escape the boundary imposed by QNX?

The stack under test:

```text
APK
 ↓
ART / Android framework
 ↓
Android UID/GID + sandbox
 ↓
libbionic QNX security glue
 ↓
QNX abilities
 ↓
Pathtrust
 ↓
QNX kernel
```

Factory primitives that become testable: `defineAppSandbox`,
`checkAppCapabilities`, capability retention and dropping,
`dropWriteAndExecSystemCapabilities`, UID/GID mapping, Pathtrust,
filesystem boundaries. Optional shortcut: link against the factory
`libbionic.so` binary itself (265 exported sandbox functions, already a QNX
ARM ELF on the device) so we test the existing boundary instead of
reimplementing it. Deliberate attack probes: filesystem escape, raw device
access, process signalling, privileged binder, memory access.

### Phase 5: minimal Android consumer

```text
ART
 ↓
process spawning
 ↓
Binder
 ↓
minimal framework
 ↓
APK
```

The factory precedent matters here: the Hub does not have to be a native
QNX application. The factory runtime already shipped
`QNXAppLauncher.apk` and Hub style apps as Android APKs.

### Phase 6: security hardening

Only once a real APK consumer exists: filesystem isolation, QNX abilities,
Pathtrust, UID/GID isolation, privileged and unprivileged separation,
keystore, encrypted storage, minimal service set, no GMS, attack surface
measurement. Measure actual security properties, not speculative
infrastructure.

### Phase 7: selective modernization

Do not upgrade for its own sake. Upgrade a component only when a concrete
reason exists: our QNX platform abstraction can support component X and a
newer Android gives a specific property that materially improves the
result. The stanw47 repo already contains an Android 11 binder for QNX plus
AOSP 11 framework material as the eventual trajectory.

```text
Android 6   -> prove the QNX Android architecture
Android 8/9 -> modernize framework and security, selectively
Android 11  -> selectively backport security fixes
```

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
