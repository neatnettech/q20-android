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
