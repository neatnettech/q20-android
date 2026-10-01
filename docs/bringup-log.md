# On-device bring-up log

Record of the ART 6.0.1 on Q20 bring-up, in the order the problems were
found and fixed. All of this happened on a live Classic via dev-mode SSH.

## Fixes applied to reach "runtime initializes"

| Problem | Fix |
|---|---|
| QNX sysroot lacks bionic/glibc headers | `runtime/art-qnx/compat/` shims (valgrind.h, memcheck, stdatomic.h, sys/ucontext.h, sys/syscall.h, link.h, byteswap.h, sys/sendfile.h, sys/prctl.h, sys/xattr.h, linux/*, netpacket/packet.h, openssl/opensslv.h) |
| ART uses futexes | `ART_USE_FUTEXES=0` on QNX (pthread fallback), patch 0010 |
| Debug-only stream operators never defined in 6.0.1 | `src/debug_operators.cc` defines them all |
| zip_archive/backtrace/nativebridge/atrace deps | stubs in `src/` with `ponytail:` markers |
| ARM signal context layout | `compat/qnx_sigcontext.h` + patched fault_handler_arm.cc |
| QNX main thread stack query | GetThreadStack parses `/proc/self/mappings` `{stack}` pages |
| no ashmem | `ashmem_create_region` via unlinked temp file in /tmp |
| no dl_iterate_phdr in SDK | real implementation over `/proc/self/mappings` + phdrs read from mapped memory, page-aligned segments |
| QNX procfs pathnames go stale after rename | read ELF phdrs from memory, not fopen |
| no sendfile | copy loop in libjavacore |
| no sigaltstack | implicit SO checks disabled (patch 0010), interpreter fallback |
| getpwuid_r buffer sizing | sysconf returns -1 on QNX, clamp to 4096 (patch 0020) |

## Boot sequence milestones reached on-device

1. dalvikvm loads libart.so, parses options, opens boot classpath dex files
2. Imageless boot: GC heap created, class loading started, failed on
   FindClass during Runtime.<clinit> (needs the boot image)
3. Boot image path: hammerhead M4B30X `boot.art` + `boot.oat` extracted
   from the factory image (sparse image converted with a Python parser)
4. Boot image loads: sections dumped, oat dlopened at exactly the expected
   addresses, GC heap + all spaces initialized
5. libjavacore (OsConstants, File, FileDescriptor, System, Memory, Posix:
   148 natives) registers cleanly
6. First oat compiled code execution crashes: NULL jump, LR inside the oat
   code section

## The remaining wall

The factory boot.oat code section contains absolute pointers to the
hammerhead libart.so (quick entrypoints, resolution stubs). Under our
libart.so those addresses are unmapped, so the first managed call jumps to
NULL. A foreign boot image can never execute under a different libart.so.

Conclusion: build `art/compiler` + `art/dex2oat` for QNX and generate the
boot image from the extracted dex on-device, so image and libart addresses
match.

## Censored content

The device password and SSH keys used during bring-up live only in local
temporary files outside this repository. Nothing device-identifying is
committed.

## dex2oat on QNX (2026-09-23)

Built `dex2oat` (Quick backend only) and got it running on the Q20. The
first on-device compilation succeeded: `hello.dex` -> `hello.oat` (17.7KB),
proving the whole chain (runtime + driver + Quick ARM backend + oat writer)
works on QNX.

Fixes that fell out:

* `BacktraceMap` was a null stub; dex2oat needs it for `ContainedWithinExistingMap`.
  Real implementation now parses `/proc/self/mappings` (CSV, one line per
  page, header first), merging consecutive pages with the same protection
  and name. Linux `/proc/<pid>/maps` kept as fallback.
* ashmem shim moved from `/tmp` (RAM backed on QNX, 512MB regions fail) to
  `ANDROID_DATA/tmp` on flash.
* Heap caps: 256MB works, 512MB anonymous mmap fails on QNX.
* `--compiler-backend=Quick` is mandatory (6.0 dex2oat defaults to the
  optimizing backend, which is not built).
* `BacktraceMap` constructor/destructor/ParseLine live in the stub now.

## Boot image build from quickened factory dex

The dex extracted from the factory boot.oat is quickened (invoke/iget
`-quick` opcodes). AOSP never feeds quickened dex to dex2oat, so three
changes were needed (patch 0040):

1. Verifier: accept quick opcodes in AOT mode instead of failing with
   "opcode only expected at runtime" (the verifier has full quick opcode
   handling via GetQuickInvokedMethod / GetQuickFieldAccess).
2. `VerifiedMethod`: generate the dequicken map for AOT, not only JIT, and
   drop the UseJit DCHECK in GetDequickenIndex.
3. Boot classpath verification failures are warnings now, not fatal DCHECKs
   (AOSP builds boot images with release dex2oat; our debug DCHECKs fired
   on icu classes).

Also: `-DNDEBUG` for release semantics like AOSP's own boot image builds,
and `framework.dex:classes2.dex` renamed to `framework2.dex` because the
colon splits the boot classpath (multidex jar support still needs a real
zip archive).

State: boot image build (13 dex files, base 0x70000000) gets through
verification of core-libart and deep into framework/telephony classes. A
SIGSEGV appears during the parallel compile phase (after verifying
SIMRecords.handleMessage). `-j1` run started to separate a race from a
deterministic crash; device dropped off USB before the run finished.

## SIGSEGV in the boot image build (2026-09-25)

The boot image build (13 dex files, -j1, -Xmx256m) crashes with SIGSEGV
during framework compilation. The crash point drifts across methods
(SIMRecords.handleMessage, org.apache.http.util.VersionInfo.toString,
xalan classes), always in the same code.

### Crash signature

* `pc` = dex2oat + 0x8998e = `ObjectReference<false, Class>::UnCompress`
  reading `[r3]` with r3 = 0xc
* `lr` = dex2oat + 0x878a3 = `AsMirrorPtr` frame
* Call chain: `IsArrayClass` -> `GetComponentType` -> `AsMirrorPtr` ->
  `UnCompress` on a NULL Class pointer (component_type_ sits at offset 0xc)
* Stack scan shows MarkSweep GC frames below the crash (RunPhases,
  MarkingPhase, ScanObject, ProcessMarkStack): a GC runs mid-compile and
  marks an object whose class pointer is NULL
* r0-r3 = 0xc constant across every run; pc/lr offsets identical across
  runs and ASLR

### Instrumentation added (patch 0050)

* Fault handler now dumps registers, library mappings, a stack scan, and
  dladdr-resolved frames (runtime_qnx.cc)
* Null guards in `RegTypeCache::GetComponentType` and `ClassJoin`
  (FindArrayClass failure) with warning logs: never fired
* `ScanObjectVisit` LOG(FATAL) on null-class objects: never fired before
  the crash
* Per-method verifier LOG(INFO): crash follows verification, not a
  specific method
* DexToDex pass logging: the dex-to-dex quickening never runs, so the
  crash is not in that pass

### Current hypothesis

Heap corruption during GC marking: an array object on the GC heap has a
NULL class pointer. Suspects, in order:

1. The QNX ashmem shim (flash-file-backed region): GC main space uses it;
   QNX mmap semantics for unlinked files may differ (MAP_SHARED
   re-mapping, COW behavior)
2. The imageless boot build heap layout (no image space, malloc space +
   ashmem main space + non-moving space)
3. A class linker allocation path writing an object's class field
   without the write barrier during compilation

### Ideas to pursue next

* Enable QNX core dumps and inspect the heap with the toolchain gdb
* GC bisect: `-Xgc:noconcurrent`, smaller heaps, `-XX:HeapGrowthLimit`
* Test the ashmem shim with plain mmap instead of file-backed ashmem
* Check the CMS card table / remembered set against QNX mmap behavior

## GC crash: zeroed object at main space + 0xf90 (2026-09-26)

The first GC during the boot image build crashes marking an all-zero
object near the start of the main heap space. Every run, both RosAlloc and
dlmalloc allocators: object address = main_space_begin + 0xf90, content
`0 0 0 0 0 0 0 0` (never written), yet present on the allocation stack.

Findings:

* Fault handler secondary crashes (stack scan past guard pages) masked the
  real signature at first; the kernel report (Process ... terminated ...
  ip= ref=) is the authoritative one
* The zeroed object is reached from the allocation stack, not from a
  parent scan (MarkObject holder log never fires for it)
* Instrumenting allocations shifts the crash (order-dependent corruption)
* Skipping the post-initialize prune GC and System.gc gets further, but
  other GC triggers (heap pressure) still crash

Workarounds in the tree (patch 0050): prune GC and explicit GC skipped on
QNX, RosAlloc replaced by dlmalloc. The root cause is still open; prime
suspects are the per-thread allocation stack bookkeeping and the GC root
visiting of dex caches on QNX.

Next steps: trace the allocation stack source of the bogus entry, enable
QNX core dumps for gdb inspection, or bisect with the earliest possible GC.

## GC crash root cause: card table clearing (2026-09-28)

The zeroed object was not corruption, it was ART zeroing the heap on purpose.

`CardTable::ClearCardRange` has a `!kMadviseZeroes` branch that does
`memset(start, 0, end - start)`. `start` and `end` are heap addresses, not
card addresses, so the branch memsets the space it was asked to clear cards
for. `kMadviseZeroes` is false on every target that is not `__linux__`
(`art/runtime/mem_map.h`), so this branch is always taken on QNX and never on
Android or Linux, which is why upstream never noticed.

The single caller is `Heap::ProcessCards`, which passes `space->Begin(),
space->End()` for each alloc space without a mod union table, reached from
`MarkSweep::MarkingPhase` with `clear_soft_references` handling for any
non-sticky GC. So the first full or partial GC wiped the whole main space
before marking it, and marking then walked objects whose class pointer had
just been zeroed.

Every symptom follows: the object at a fixed offset from the space start, the
all-zero content, allocator independence (RosAlloc and dlmalloc both), the
crash moving when allocation was instrumented, and sticky GCs surviving.

Patch 0060 clears the cards covering the range instead. The workarounds from
the previous session are reverted: RosAlloc is the allocator again, and the
prune and explicit GCs run again (patches 0040 and 0050 no longer skip them).

`Hello.java` now builds its message on the heap through StringBuilder and
calls `System.gc()` before printing, so the printed line is itself the GC
regression check.

Status: built 2026-09-28, not yet run on the device. Dev mode SSH was closed
and the key push failed, so the fix is unverified on hardware.

## Second blocker for Hello: missing ICU and charset natives (2026-09-30)

Found by reading the startup path, not on the device. A working boot image
alone would not have printed anything.

`Runtime::Start` calls `InitNativeMethods`, which loads libjavacore and then
runs `WellKnownClasses::LateInit`. LateInit caches `Runtime.nativeLoad`, and
looking up a method runs the class initializer, so `Runtime.<clinit>` and then
`System.<clinit>` execute. `initUnchangeableSystemProperties` calls
`ICU.getIcuVersion`, `getUnicodeVersion` and `getCldrVersion`. Our libjavacore
registered 6 of 39 native modules and none of those three, so the call threw
`UnsatisfiedLinkError`, the method id came back null, and `CacheMethod` did
`LOG(FATAL)`.

Separately, `System.out.println` reaches `Charset.forName("UTF-8")` through
`String.getBytes()`, which calls `NativeConverter.charsetForName`.

dex2oat cannot pre-initialize `System` into the image: it never starts the
runtime, class initializers run inside a transaction that aborts on any native
not listed in `unstarted_runtime_list.h`, and without `--image-classes` no
initializer runs at compile time at all.

`runtime/art-qnx/src/icu_stubs.cc` registers four natives: three constant
version strings and a `charsetForName` that recognises only the charsets whose
encoder is an ART native inside `String.getBytes` (UTF-8, ISO-8859-1,
US-ASCII, UTF-16BE). No ICU library and no `icudt55l.dat` are needed. A decode
or any other charset still fails, which is correct until ICU 55 is cross
built.

## Device runner is versioned now

The on-device invocation used to live only in a shell script under `/tmp`. It
is `runtime/art-qnx/device/run_core.sh` now, with `core` (4 dex image),
`boot13` (full 13 dex image), `hello` (AOT then interpreter) and `all`
targets. `make -f art-qnx.mk stage` assembles the staging directory, including
the rename of `framework.dex:classes2.dex` to `framework2.dex`.

The makefile no longer swallows compile and link failures: a failing rule
fails the build, and `make -k` is the way to sweep for errors instead.

The build environment was also unreproducible: the compose file referenced an
image (`q20-aosp6:trusty`) that no longer exists locally and there was no
Dockerfile, while the PlayBook GCC 9.3 toolchain is a Linux x86-64 binary and
cannot run on the macOS host at all. There is a `Dockerfile` now (ubuntu 24.04
plus make, patch, python3 and the gcc runtime libraries), wired into
`docker-compose.yml`. Verified by rebuilding `libjavacore.so` with the new ICU
stubs inside the container, and by disassembling `ClearCardRange` in the staged
`libart.so`: it computes the card addresses and memsets the card range, so the
Sep 28 binaries do carry the fix.

## First full device session since the card table fix (2026-09-30)

### Device access, solved

Dev mode was on (port 4455 answering) but sshd was not listening, because the
SSH key install had never succeeded. Two failures and their causes:

* A 4096 bit key with a comment field is rejected: "Invalid contents after ssh
  key". The device parser stops after the base64 blob and treats the comment as
  junk.
* A 2048 bit key is rejected with "Provided ssh key is too small (4096 bit
  minimum)".

What works: RSA 4096, public key file reduced to exactly two fields
(`ssh-rsa <blob>`), no comment. `blackberry-connect` (Connect.jar, shipped in
the toolchain at `qnx650/x86_64-linux/lib/`) then installs it and must keep
running, because that process holds the authorized session that keeps sshd
listening.

The device's sshd is OpenSSH 6.2 on QNX and drops the connection during key
exchange with modern defaults. It needs legacy algorithms:

```
-o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa
-o KexAlgorithms=+diffie-hellman-group14-sha1 -c aes128-ctr -m hmac-sha1
```

Device identity: `QNX BLACKBERRY-F9D7 8.0.0 2018/02/21 MSM8960_V3.2.1.1_F_CLASSICROW_Rev:11 armle`.
Login is `devuser`, home `/accounts/devuser` on flash, 7.4 GB free, about
3.5 MB/s over the USB link.

Device shell quirks that broke scripts: `/bin/sh` is ksh, and `head`, `tr`,
`nohup`, `id` and `whoami` do not exist. `sed 20q` replaces `head -20`. Use a
held SSH connection instead of nohup. scp is unreliable against this sshd, so
`cat file | ssh 'cat > dest'` is the transfer method, and tar over ssh for
trees.

### Patch 0060 confirmed on hardware

The card table fix works. Two full mark sweep collections completed during the
core image build:

```
Explicit concurrent mark sweep GC freed 13932(1361KB) AllocSpace objects, 56% free, 3MB/7MB, paused 1.007ms
Explicit concurrent mark sweep GC freed 6442(1600KB) AllocSpace objects, 64% free, 2MB/6MB, paused 0
```

Before the fix the first GC always died marking a zeroed object. RosAlloc is
the allocator again, and the prune and explicit GCs are no longer skipped. The
heap stays small during a core image build: it peaked at 7 MB.

### New blocker: image writer finds an ArtField with no relocation entry

The build now reaches image writing and fails there. The visible symptom was a
SIGSEGV, but that was the logging code: `FixupPointerArray` takes its
`LOG(FATAL)` branch and builds the message with `PrettyField`, which goes
`ArtField::GetTypeDescriptor` to `GetDexFile` to
`GetDeclaringClass()->GetDexCache()->GetDexFile()`, and the dex cache is NULL.
Patch 0070 prints the raw pointers first, which produced the real diagnostic:

```
No relocation entry for ArtField @ 0x1153b438 idx=672/15799 dex_field_index=672
access_flags=0x1a declaring_class=0x16340470 dex_cache=0 array=0x10d91000
```

So a DexCache resolved fields array (15799 slots, so core-libart) still points
at an ArtField whose declaring class has no dex cache by the time the image is
written.

### Missing flag found: --image-classes

A boot image build needs `--image-classes`. Without it dex2oat creates an empty
image class set (`art/dex2oat/dex2oat.cc:1223`), so
`CompilerDriver::IsImageClass` answers false for every class and
`PruneNonImageClasses` strips all of them. AOSP always passes it:
`art/build/Android.oat.mk:111,229` use
`--image-classes=$(PRELOADED_CLASSES)` for both the host and target core
images. `frameworks/base/preloaded-classes` is in the tree (3832 entries) and
is now staged and passed.

Adding it changed GC behaviour (different numbers of objects freed) but the
image writer still fails the same way.

### What the evidence rules out

* Not a bound mismatch in the prune loop: `DexCache::NumResolvedFields()` is
  defined as `GetResolvedFields()->GetLength()`
  (`art/runtime/mirror/dex_cache.h:88`), the same length the image writer
  iterates, so slot 672 was covered by the pruning pass.
* Not specific to the concurrent collector: `-Xgc:nonconcurrent` produced an
  identical crash with identical numbers of freed objects, so the concurrent
  only paths (root checkpoints, the new roots log) are not the difference.

That leaves two live hypotheses, in order: the GC at
`art/compiler/image_writer.cc:101` frees a class that pruning decided to keep,
or the declaring class was never registered in the class table and is
legitimately garbage that pruning failed to notice.

### Diagnostics still masked

* The fault handler's conservative stack scan walks past the end of the mapped
  stack and faults, so the kernel report describes the handler's own second
  fault. The dladdr attribution in those reports is also misleading: it names
  the nearest exported symbol, `X86InstructionSetFeatures::FromBitmap`, for
  code that has nothing to do with x86. Resolving `mapaddr` or the printed pc
  against the binary with addr2line is the reliable method.
* No core file is produced despite "core dumped", and the toolchain ships no
  cross gdb, so addr2line over the fault handler's scan is currently the only
  backtrace method.

### 2026-10-01: root cause, fix, and first managed execution

The slot 672 dangling field was chased with three probes in one binary:
a write tracer in `ClassLinker::FindField`/`ResolveFieldJLS`/
`InitializeClass`, slot-672 read checkpoints around the prune and the GC, and
raw array reads at prune time. Findings:

* Slot 672 of core-libart's dex cache is written once, early (line 1505 in the
  log), by a FindField resolving `android.icu.impl.PluralRulesLoader.UNKNOWN_RANGE`.
* At prune time the slot is populated, but the prune loop saw it as empty:
  `DexCache::GetResolvedField()` returns nullptr for fields whose declaring
  class is erroneous, so `PruneNonImageClasses` never cleared the slot.
* Why is PluralRulesLoader erroneous? The factory boot dexes are quickened,
  and its `<clinit>` contains `invoke-virtual-quick`:
  `Verification error in void android.icu.impl.PluralRulesLoader.<clinit>()`
  ... `Cannot infer method from invoke-virtual-quick`. Two classes fail this
  way (PluralRulesLoader and android.icu.text.PluralRules), both soft failures
  in dex2oat.
* Prune then removes the erroneous class (not an image class), the explicit GC
  reclaims it, and FixupPointerArray dies on the dangling ArtField.

Fix in PruneNonImageClasses: read the raw array element
(`GetResolvedFields()->GetElementPtrSize`) instead of the filtered
`GetResolvedField`, so fields of erroneous classes are cleared like any other
non-image class. Patch 0070 now carries both the diagnostics and this fix.
M1 (core image) builds clean: core.art 3.0 MB, core.oat 23.5 MB, heap peaked
at 7 MB.

### M2: Hello World runs, both modes

* hello.oat compile needed image-only flags removed (`--image-classes`,
  `--base` are rejected for non-image builds) and `-Xnorelocate` (there is no
  patchoat on this port).
* AOT: prints `Hello from ART 6 on QNX! gc ok`, exit 0. Hello.main ran the
  Quick-compiled code from the dalvik-cache oat (no interpreter entry for it).
* -Xint: initially a deterministic SIGSEGV at the top of
  `ExecuteGotoImpl` (a store into its freshly allocated frame) right after
  printing, on the finalizer thread while it ran its exit bookkeeping
  (ThreadGroup.removeThread and the CollectionUtils chain), fully interpreted.

Two QNX stack bugs behind it:

1. `GetThreadStack` merged every thread's {stack} pages into one range, so
   every thread got the lowest thread's stack base. The interpreter overflow
   check (frame address < stack_end) could never fire for threads above the
   lowest one. Fixed by picking the {stack} run that contains a local
   variable's address (patch 0010, GetThreadStack section).
2. The interpreter is built -O0 in the bring-up build, giving ExecuteGotoImpl
   a ~17 KB frame per invocation. QNX grants threads far less stack than the
   requested 8 MB (attached threads observed at 128 KB). The interpreter files
   are now always built -O2 (art-qnx.mk), which AOSP also does.

With both fixes, the deep finalizer exit chain fits and both modes exit 0.
`sh run_core.sh all` is green end to end: core image, hello.oat, aot and int.

Known follow-ups, none blocking:

* Quickened opcodes fail verification in the port's verifier
  (invoke-virtual-quick), so android.icu plural classes are unusable at
  runtime until the verifier learns quickened opcodes or the dexes are
  unquickened. Patch 0040 covers the compiler side only.
* The runtime still attempts `execv` of dex2oat (fork fails on QNX with
  "Not enough memory") when an oat is missing; the precompiled-oat path
  avoids it.
* `Current thread not detached in Runtime shutdown` warning at exit, cosmetic.

### 2026-10-01: quickened verifier fix, all boot classes verify

Five boot classes failed verification in every build
(PluralRulesLoader, PluralRules, MeasureFormat, CurrencyFormat,
TimeUnitFormat), all for the same reason: the factory dexes are quickened,
and the verifier hit an invoke-virtual-quick whose receiver register type
has no class (provably null, in PluralRulesLoader.<clinit> at dex_pc 0xDD5:
`invoke-virtual-quick {v3}, vtable@16`). The original method index is
unrecoverable from a vtable index without a receiver class, but such an
invoke throws NPE at runtime and never returns, so the verifier now accepts
it conservatively (result register left unknown). The same treatment for
quickened field accesses with a classless object register: a quick get sets
the destination to Conflict.

Patch 0040 carries the change. Confirmed on hardware: boot13 builds with zero
verification failures, and at runtime PluralRules loads, verifies, and runs
its <clinit> under -Xint.

The next gap on the ICU path is unrelated to quickening: java.util.regex
needs its libjavacore natives (Pattern.compileImpl etc.), still deferred
with the other framework natives.

