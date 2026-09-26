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
