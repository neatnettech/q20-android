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
