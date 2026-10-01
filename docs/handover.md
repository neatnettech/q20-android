# Handover: Android 6 on QNX (Q20), 2026-10-01 (M1 and M2 done)

Read `docs/bringup-log.md` for the full history. This file is what to do next.

## Status in one paragraph

The ART runtime, the Quick compiler and dex2oat all run on the phone. The GC
bug is fixed and confirmed on hardware. The core boot image builds
(`core.art` 3.0 MB, `core.oat` 23.5 MB, exit 0) and **Hello World runs in
both modes**: AOT executes the Quick-compiled hello.oat and -Xint interprets,
both printing `Hello from ART 6 on QNX! gc ok` and exiting 0. The two bugs
that blocked M1 and M2 were a dex cache prune hole for erroneous classes
(quickened dex fails the verifier for two android.icu classes) and a pair of
QNX thread stack bugs that let the interpreter overflow the finalizer's stack
at exit. Nothing is committed yet.

## Milestones

| ID | Goal | Exit criteria | State |
|---|---|---|---|
| M1 | Core boot image builds | `dex2oat` exits 0 and writes `out/arm/core.art` plus `core.oat` from the 4 core dex files | done, confirmed on device |
| M2 | Hello World executes | device prints `Hello from ART 6 on QNX! gc ok` under the core image, both AOT and `-Xint` | done, confirmed on device |
| M3 | Full boot image | same for the 13 dex boot image, `boot.art` plus `boot.oat` | done, confirmed on device |
| M3.5 | Quickened verifier | all boot classes verify despite quickened opcodes (patch 0040), proven at runtime by loading android.icu.text.PluralRules | done, confirmed on device |
| M4 | Land the work | patches 0010 to 0070, stubs, device runner, Dockerfile committed on `fix/gc-card-table`, PR to main, README and bringup log updated with the measured numbers | commit pushed, PR pending |
| M5 | Platform hygiene | release build (`-O2`, stripped), fault handler stack scan bounded, verbose per method verifier logging behind a flag | after M4 |
| M6 | APK path | replaced by the concrete ladder in `docs/apk-milestones.md`: the Q20 Prober APK, milestones A1 to A10 | start with A1 |

M3 and M4 are the whole job right now, then the A ladder. Everything beyond
M4 is scoped in the plan file at
`~/.claude/plans/i-was-looking-into-virtual-jellyfish.md` and in
`docs/apk-milestones.md`.

## What fixed M1: erroneous class fields were never pruned

`ImageWriter::FixupPointerArray` found dex cache slot 672 of core-libart still
pointing at an ArtField whose declaring class was reclaimed. The chain:

1. The factory boot dexes are quickened; `PluralRulesLoader.<clinit>` contains
   `invoke-virtual-quick`, so the verifier rejects the class
   (`Cannot infer method from invoke-virtual-quick`) and marks it erroneous.
   Same for `android.icu.text.PluralRules`. Soft failure in dex2oat.
2. `DexCache::GetResolvedField()` returns nullptr for fields of erroneous
   declaring classes, so `PruneNonImageClasses` saw slot 672 as empty and
   kept it.
3. Prune removed the erroneous class (not an image class), the explicit GC at
   image_writer.cc:101 reclaimed it, and FixupPointerArray died on the
   dangling ArtField.

Fix: PruneNonImageClasses reads raw array elements. Patch 0070 carries the
diagnostics (raw pointer logging, safe against missing dex caches) plus this
fix. Also needed: `--image-classes` on the image build (mandatory, staged),
and image-only flags must not leak into the standalone hello compile.

## What fixed M2: two QNX thread stack bugs

The -Xint run died at the top of `ExecuteGotoImpl` (a store into its freshly
allocated frame) on the finalizer thread running its exit bookkeeping,
fully interpreted.

1. `GetThreadStack` merged all threads' {stack} pages from
   `/proc/self/mappings` into one range, so every thread got the lowest
   thread's stack base and the interpreter overflow check could never fire
   for the rest. Fixed by picking the {stack} run containing a local
   variable's address (patch 0010, GetThreadStack section).
2. The bring-up build compiles the interpreter at -O0, giving ExecuteGotoImpl
   a ~17 KB frame per call, while QNX grants threads far less than the
   requested 8 MB (attached threads observed at 128 KB). The interpreter
   files are now always built -O2 in art-qnx.mk, matching AOSP.

## Reconnecting to the phone

Dev mode must be on, and the key install must be redone after a reboot. Port
4455 answering means dev mode is on; port 22 closed means the key is not
installed yet.

1. `sh runtime/art-qnx/device/connect.sh` generates an RSA 4096 key with no
   comment field (both are hard requirements), installs it through
   blackberry-connect, and must stay running: it holds the session that keeps
   sshd alive. Reads the device password from `$BBPW`:
   `read -rs "?password: " BBPW && echo && BBPW="$BBPW" sh connect.sh`.
   Needs a real JRE: `JAVA=/opt/homebrew/opt/openjdk/bin/java` works.
2. Connect through `runtime/art-qnx/device/q20ssh` and `q20put`, which carry
   the legacy algorithm set this OpenSSH 6.2 needs. scp does not work; use
   tar over ssh for trees.

## Running the build on the device

The staging tree is at `/accounts/devuser/q20-stage`. Rebuild and restage with

```
docker compose run --rm --entrypoint /bin/bash aosp6 -c \
  '. toolchains/playbook-gcc9/env.sh && cd runtime/art-qnx && make -f art-qnx.mk stage'
```

The container is mandatory: the toolchain is a Linux x86-64 binary. After a
restage, push `build/stage/bin/dex2oat` and `build/stage/lib/libart.so` (and
`run_core.sh` if it changed) with `q20put`.

On the device, from the staging dir:

```
sh run_core.sh core      # 4 dex core image, about 4 minutes, exit 0
sh run_core.sh hello     # AOT compile Hello against the image, then run AOT and -Xint
sh run_core.sh boot13    # the full 13 dex boot image, the next milestone
sh run_core.sh all       # core then hello
DEX2OAT_EXTRA="--runtime-arg -Xgc:nonconcurrent" sh run_core.sh core   # experiments
```

Logs land in `out/`: `core-dex2oat.log`, `hello-dex2oat.log`, `hello-aot.log`,
`hello-int.log`.

## Reading a crash

The kernel's "terminated SIGSEGV" line usually describes the fault handler's own
second fault, and its symbol name is the nearest exported symbol, which is
routinely wrong (it likes `X86InstructionSetFeatures::FromBitmap`). Use the
`art: fatal signal` line's pc and lr, subtract the binary's load base from the
`art: map` line for that binary, and resolve offsets with

```
arm-blackberry-qnx8eabi-addr2line -f -C -i -e build/stage/bin/dex2oat 0x<offset>
```

The `art: scan` line is a conservative stack scan. Pulling every word in the
binary's address range out of it and resolving each one reconstructs a usable
backtrace, which is how the image writer blocker was found.

## What is in the working tree, uncommitted

New files:

* `runtime/patches/0060-card-table-clear-range.patch`, the GC fix, confirmed on
  hardware.
* `runtime/patches/0070-image-writer-field-diagnostics.patch`, safe logging for
  the missing relocation entry plus the erroneous class prune fix. Confirmed on
  hardware.
* `runtime/art-qnx/src/icu_stubs.cc`, four natives that Hello needs. Compiled
  into libjavacore.so, exercised by both hello modes now.
* `runtime/art-qnx/device/`, the device runner plus the connection scripts
  (`connect.sh`, `q20ssh`, `q20put`) and a README explaining the key shape and
  the missing device utilities.
* `Dockerfile`, because the referenced build image was gone and the toolchain
  cannot run on macOS.

Modified: `README.md` status and stale claims, `docs/bringup-log.md`,
`runtime/art-qnx/art-qnx.mk` (stage target, hard failures on compile and link
errors, icu stubs, interpreter files forced to -O2), patches 0010 and 0070
updated to match the tree, `docker-compose.yml`, plus the patch path rewrites
from the previous session.

Nothing is committed on purpose: git history should not claim a verified fix
before the hardware confirms it. M1 and M2 are that confirmation; commit after
M3.

## Facts worth not rediscovering

* `--image-classes` is mandatory for an image build. Without it the image class
  set is empty and every class gets pruned.
* `--image-classes` and `--base` are rejected for non-image compiles, and a
  compile against a boot image needs `--runtime-arg -Xnorelocate` because this
  port has no patchoat.
* `DexCache::GetResolvedField()` hides fields of erroneous classes. The prune
  loop must read raw array elements.
* The factory dexes are quickened. The verifier accepts quickened invokes and
  field accesses even when the receiver register has no class (patch 0040):
  such accesses throw NPE at runtime, so they are safe to accept with an
  unknown result. All boot classes verify now.
* The next runtime gap is libjavacore natives for java.util.regex
  (Pattern.compileImpl and friends); PluralRules.<clinit> reaches Pattern
  compile and dies on the missing native. Same bucket as the crypto, zip and
  expat natives, deferred to the framework milestone.
* QNX thread stacks are far smaller than requested (attached threads observed
  at 128 KB), so the interpreter must stay at -O2; at -O0 its 17 KB frames
  overflow them.
* `PrettyField`, `PrettyClass` and `PrettyMethod` are not safe in error paths:
  they need a dex cache. Log raw pointers first.
* ashmem is a `/dev/zero` mapping and `MAP_PRIVATE`, so nothing is shared
  between processes. That is fine for dex2oat and fatal for a fork based
  zygote later.
* The heap stays tiny during a core image build, 7 MB peak, so `-Xmx256m` is
  generous and heap pressure is not a factor.
