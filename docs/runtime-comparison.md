# Q20 Android 4.3 runtime vs Android 6.0.1: side-by-side analysis

Status: verified against extracted Q20 Classic (PRD-64100, OS 10.3.3) runtime
binaries in `Blackberry-Research/specimens/` and the AOSP 6.0.1_r81 source
tree (`art/`, `bionic/`, `libcore/`, `frameworks/base/`, `system/core/`).

All findings below were verified by disassembly or symbol inspection, not
assumed. Disassembly was done with capstone 5 on the raw ELF because QNX ELF
section headers break LLVM/GNU objdump.

## 1. What the Q20 runtime actually is

The factory Android runtime is a **full Android 4.3 userland running as QNX
processes**, rooted at `/apps/sys.android.<namespace>.ns/native/` on device
(`= /system` for Android processes). Every binary is a QNX-native ARM ELF:
interpreter `/usr/lib/ldqnx.so.2`, and Android libraries link the QNX libc
directly.

Verified NEEDED of `app_process`:

```
libslog2.so.1  libcutils.so  libutils.so  liblog.so  libbinder.so
libandroid_runtime.so  libbionic.so  libm_android.so  libm.so.2
libcpp-ne.so.4  libc.so.3
```

So the layering is:

```
Android userland (app_process, system_server, dalvikvm, ...)
  ├─ libbionic.so        ← bionic→QNX interposer (85 KB, 265 exports)
  ├─ libm_android.so     ← Android libm (replaces QNX libm for Android code)
  ├─ liblog.so           ← Android log → slog2
  └─ libc.so.3 (QNX)     ← the real libc underneath
QNX kernel
```

Kernel drivers in stock Android became **QNX resource managers / daemons**
exposing device nodes. Verified from the runtime inventory and strings:

| Stock Android kernel thing | Q20 implementation |
|---|---|
| `/dev/binder` driver | `binder` binary (QNX resmgr) |
| epoll/eventfd syscalls | `epolld` daemon + `/dev/android/epoll`, `/dev/android/eventfd` |
| `/dev/lowmemorykiller` | `lowmemorykiller` daemon + `/dev/android/lowmemorykiller` |
| `/dev/log/main` + events | `logd` daemon |
| property service | `/dev/__properties__` + socket `.../tmp/property_service` |
| ashmem | `mmap_peer`/`_mmap2_peer` family in libbionic (QNX shm) |
| alarm driver | (in 4.3 mostly unused by apps) |

Daemons present in `/system/bin` (all QNX binaries): `servicemanager`,
`surfaceflinger`, `mediaserver`, `drmserver`, `keystore`, `installd`, `rild`,
`sensorservice`, `android_resmgr`, `android_launcher`, `shrimp`, `init`,
`linker` + `linker_helper`, `exe_shim`, `dalvikvm`, `dexopt`,
`bootanimation`, `system_server`.

`exe_shim` is the piece that lets Android executables run under QNX: it is
what `init.cfg` uses to start services with Android-style environment.

## 2. libbionic.so: the interposer surface (265 exports)

Grouped from the dynamic symbol table of the extracted binary:

### Standard bionic libc implemented over QNX libc
open/open64/openat, close, creat/creat64, chdir, mkdir/mkdirat/mkdtemp,
rmdir, renameat, unlinkat, stat/lstat/fstat (+64/at variants), statvfs,
fdopendir/opendir, faccessat/fchmodat/fchownat/utimensat, chown/fchown/
lchown, mknod, sendfile, fork/_fork, exec* family, getuid/geteuid/getgid/
getegid/getresuid/getresgid/getgroups, setuid/seteuid/setgid/setegid/
setreuid/setregid/setresuid/setresgid/setgroups, getpwnam(_r)/
getpwuid(_r)/getgrnam/getgrgid/getgrouplist/getlogin, getprotobyname/
getprotobynumber/getnetbyname/getnetbynumber, asctime/ctime/gmtime/
localtime/mktime/timegm/timelocal/tzset/strftime/strptime (+_r and _tz
variants), memcmp/memmem/strcasestr/strndup, poll, getpriority/setpriority,
getmntent, ttyname(_r), prctl, klogctl, cacheflush, __assert2.

### Android system properties (reimplemented over QNX)
__system_property_get/set/find/find_nth/read/wait, wait_serial/get_serial,
__system_properties_init/__do_system_properties_init,
__system_property_area__/__system_property_area_lock__ (data exports).

Mechanism (from strings): property area served via `/dev/__properties__`,
set path is a QNX-namespace socket at
`/accounts/1000/appdata/sys.android.<ns>.ns/tmp/property_service`.
Runtime status is published to PPS at `/pps/services/android/status`
(`pps_encoder_*` calls, libpps.so.1 in NEEDED).

### BlackBerry-specific glue (the part we must extend or replace)
- UID/GID mapping: `android_uid_to_qnx`, `android_gid_to_qnx`,
  `qnx_uid_to_android`, `qnx_gid_to_android`
- App sandbox: `defineAppSandbox`, `checkAppCapabilities`,
  `clrAppCapabilities`, `setUserCapabilities`, `renameUserCapabilities`,
  `dynamicUserCapabilities`, `setPermissions`, `setMediaCapabilities`,
  `setrootgroups`, `dropSetUidGid`, `dropWriteAndExecSystemCapabilities`
- Per-service capability retention (QNX procmgr_ability mapped onto Android
  service startup): `retainInitSystemCapabilities`,
  `retainSystemServerSystemCapabilities`, `retainBinderSystemCapabilities`,
  `retainEpolldSystemCapabilities`, `retainLowMemoryKillerSystemCapabilities`,
  `retainMediaServerSystemCapabilities`, `retainDrmServerSystemCapabilities`,
  `retainKeystoreSystemCapabilities`, `retainDexoptSystemCapabilities`,
  `retainRildSystemCapabilities`, `retainBootAnimSystemCapabilities`,
  `retainJavaProcessSystemCapabilities`, `retainSystemProcessSystemCapabilities`,
  `retainAdbdSystemCapabilities`, `retainAndroidResmgrSystemCapabilities`,
  `retainMinimalSystemCapabilities`
- Per-app GID lookup from path: `getAppGidFromApkSymlink`,
  `getAppGidFromAppDataSymlink`, `getAppGidFromSymlink`,
  `getAccountGid`, `getAccountPerimeterGid`, `getAndroidPlayerGid`,
  `injectAppGidIntoSupplementaryGroups`,
  `injectGidIntoSupplementaryGroups`,
  `removeGidFromSupplementaryGroups`
- Low memory killer: `lmk_register`, `lmk_set_oomadj`,
  `oomadj_extend_watchdog`, `oomadj_shrink`
- Binder ioctl: `ioctl_binder`
- Shared memory: `mmap_peer`, `mmap64_peer`, `munmap_peer`,
  `munmap_flags_peer`, `mem_offset64_peer`, `_mmap2_peer`
- Auth/quip: `authman_send`, `sendQuipEvent`
- Process scheduling: `aps_min`, `aps_move_app`, `aps_move_pid`,
  `aps_move_tid`, `aps_stop`
- Logging: `qnx_log`, `qnx_log2`, `qnx_log_enabled`, `qnx_log_init`
- Path classification: `__is_sdcard_path`, `__sdcard_adjust`, `isreg`,
  `isdir`, `islnk`
- Misc: `isAndroidClient`, `androidPlayerShuttingDown`, `fdprintf`,
  `vfdprintf`, `__libc_fatal`, `__libc_format_*`, `__malloc_mmap_flags`,
  `entry_list`/`free_list`

### epoll/eventfd (over QNX via epolld)
`epoll_create`, `epoll_ctl`, `epoll_wait`, `eventfd`, `eventfd_read`,
`eventfd_write`, `_epoll_notify_close`.

### futex (userland emulation) — see section 4

## 3. The linker

`/system/bin/linker` on device is the Android 4.3 bionic linker compiled as
a QNX binary (320 KB, 883 exports). It already exports `dl_iterate_phdr`,
`dladdr`, `dlopen`, `dlsym`, `mprotect`, `sigaction` — which covers ART 6's
linker-level requirements (`oat_file.cc:316` uses `dl_iterate_phdr`;
`thread_linux.cc:33` uses `sigaltstack`; `mem_map.cc:127` uses
`getauxval(AT_RANDOM)`). The QNX auxv needs to carry AT_RANDOM and AT_HWCAP,
or the linker must fake them; this is a to-verify item, not a confirmed gap.

## 4. Verified gap: futex

ART 6 mutex code (`art/runtime/base/mutex.cc`) uses exactly three ops:
`FUTEX_WAIT`, `FUTEX_WAKE`, `FUTEX_CMP_REQUEUE` (mutex.cc:792,
ReaderWriterMutex).

Disassembly of the Q20 `futex` (libbionic.so @ 0xc718):

```asm
lsls r0, r1, #0x18   ; op high byte
bmi  ...             ; private flag (0x80) path
bics r1, r1, #0x80   ; strip FUTEX_PRIVATE_FLAG
cmp  r1, #1          ; 0 = WAIT, 1 = WAKE
bne  0xc8dc          ; -> else path
```

At 0xc8dc: `blx 0x50d4` (__get_errno_ptr) then `movs r3, #0x59` =
**errno 89 = ENOSYS**. So the Q20 shim supports WAIT and WAKE only (with a
per-address waiters list + QNX condvar; timed wait via 64-bit timespec to
ticks conversion at 0xc7c6+). Any other op, including `FUTEX_CMP_REQUEUE`,
returns ENOSYS.

**Consequence:** ART 6 on QNX needs either a `FUTEX_CMP_REQUEUE`
implementation in the shim (waiters list already exists; requeue = move N
waiters to a second futex address, a bounded extension of the WAKE path) or
a one-line patch in ART. This is the first confirmed, concrete work item.

## 5. What Android 6 adds that the 4.3 bridge lacks

AOSP 6 bionic for ARM declares 201 syscalls (`bionic/libc/SYSCALLS.TXT`).
Systematic diff against the Q20's QNX libc.so.3 exports (2000 symbols,
parsed from the stripped ELF with a custom dynsym parser) plus the
libbionic.so exports, with QNX socket APIs counted from libsocket.so.3
(which every Android binary links). Result: 74 nominal gaps, of which the
following matter for ART:

### ART 6 hard requirements (verified by grep over art/)

| Requirement | Q20 status | Verdict |
|---|---|---|
| `futex` WAIT/WAKE | libbionic shim, userland waiters list | present |
| `futex` FUTEX_CMP_REQUEUE (mutex.cc:792) | **returns ENOSYS** (verified disasm) | **must implement** |
| `sigaltstack` (thread_linux.cc:33, PLOG(FATAL)) | **not exported anywhere on Q20** (QNX libc, linker, libbionic all checked) | **blocker; patch ART or QNX alt-stack equivalent** |
| `tgkill` (runtime.cc:381, Abort path) | absent; QNX `SignalKill_r(nd,pid,tid,sig,...)` matches semantics | shim in libbionic |
| `prctl(PR_SET_DUMPABLE)` (ZygoteHooks) | absent; QNX procmgr | shim |
| `getauxval(AT_RANDOM)` (mem_map.cc:127) | auxv via QNX linker; needs AT_RANDOM/AT_HWCAP | verify linker provides or fake |
| `dl_iterate_phdr` (oat_file.cc:316) | present in Q20's Android linker AND QNX libc | present |
| `madvise(MADV_DONTNEED)` (mem_map.cc:627) | QNX `posix_madvise` | present |
| `mremap` | not used by ART 6 (verified) | not needed |
| `getrlimit/setrlimit` | QNX libc | present |
| `personality()` (dex2oat.cc:1937) | absent | dex2oat only, guardable |

### Framework-level gaps (later milestones, not ART blockers)

- timerfd_* — absent; used by some 6.0 daemons, not core ART
- signalfd4 — absent; not used by 6.0 zygote
- xattr family — absent; installd/sdcard work
- sched_get/setaffinity — absent; QNX runmask via ThreadCtl
- mincore — comment-only in ART; not used
- splice/tee/vmsplice — absent; not needed for first milestones
- unshare/setns — absent; netd VPN namespaces, later
- dup3/pipe2, *at() variants, prlimit64 — trivial wrappers over QNX libc
  when needed
- ptrace — absent; QNX debug API instead; not needed by ART
- capget/capset — absent; QNX procmgr_ability (libbionic already maps
  Android caps to QNX abilities via defineAppCapabilities etc.)

## 6. What the Blackberry-Research repo already provides

- `binder/` — a **complete Android 11 binder resmgr port** for QNX with a
  portable engine, host-validated (24 ABI asserts + 23 engine checks + 6
  glue checks, ASan clean). This is *ahead* of our Android 6 target; the
  same engine can serve the 4.3-era protocol if we keep the old libbinder.
- `graft/a11-frameworks-native/` — AOSP 11 libbinder + servicemanager source
- `graft/a11-kernel/binder.c` — AOSP 11 kernel binder reference
- `graphics/src/gralloc_qnx.c` — started gralloc→QNX bridge
- `specimens/a11_art_apex/` — AOSP 11 ART binaries (reference target)
- `specimens/passport_a11/` — real device AOSP 11 libbinder
- `sysroot/` — QNX cross-compilation sysroot
- Device is **rooted** (getroot + pathtrust whitelist), SSH ritual
  documented in `connect_now.py`; eMMC readable via g_Disk_Drivers

## 7. Immediate work items

1. Implement `FUTEX_CMP_REQUEUE` in the futex shim (bounded change to the
   existing waiters-list code) — first ART blocker.
2. Resolve `sigaltstack`: verify on-device whether QNX 6.6 kernel supports
   alt stacks (test program via SSH); if not, patch ART thread_linux.cc to
   a QNX-compatible setup or accept missing SO-check robustness for
   milestone 1.
3. Add small shims in libbionic: `tgkill` (SignalKill_r), `prctl(PR_SET_DUMPABLE)`.
4. Verify auxv (AT_RANDOM/AT_HWCAP) reaches ART through the Q20 Android
   linker; fake in the linker if absent.
5. Rebuild the bionic linker for 6.0 semantics against QNX libc.
6. Decide protocol version: keep the Q20's 4.3 binder protocol (works with
   the shipped `binder` resmgr) or adopt the repo's A11 resmgr port and
   build libbinder from `graft/` source. For a first ART milestone the 4.3
   resmgr + stock `libbinder.so` is enough; framework upgrades can follow.
