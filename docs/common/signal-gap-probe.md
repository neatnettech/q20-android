# Signal native-lib gap probe (NOD-16) - GO

Probe of 2026-11-05. Subject: Signal Android 8.34.2 website-prod universal APK
(`https://updates.signal.org/android/Signal-Android-website-prod-universal-release-8.34.2.apk`,
sha256 `ca516bdc9cda4a9eef95ad772c2f73311922ff791b58c90a76d68033f20bfef6`,
109.9 MB, 12 armeabi-v7a libs).

## Verdict

**GO.** minSdk is **23** (Android 6.0 - exactly our API level; targetSdk 36).
The native gap is a **shim layer, not a kernel port**: 57 unique undefined
symbols against the platform union, and most of them are free or easy.

## Method

Per `.so`: `readelf -d` (NEEDED) + `nm -D --undefined-only`, version suffixes
stripped on both sides (bionic uses `@LIBC` versioned refs, QNX libs do not
version - naive diffing overcounts ~4x: 849 raw -> 243 normalized -> 100 true).

Baseline ("what my stack provides") = factory QNX bionic `{libc,libm,libdl}.so`
(sys.android runtime) + PlayBook NDK `{libc.so.3, libm.so.2, libsocket, libz}` +
my staged `{libstdc++.so.6, libgcc_s.so.1}` + the liblog shim
(`__android_log_*`) + the Signal libs' own exports.

Note: the factory bionic libc is a **thin shim over QNX libc** (1020 dynsyms,
no memset/close/read/write - those come from QNX libc.so.3). The `libc.so`
name collision (bionic vs QNX) is a loader detail to handle at stage time,
not a symbol gap.

## NEEDED summary

`libdl/libc/libm` everywhere; `liblog` x4 (my shim); `libandroid` x2;
`libz` x1 (NDK has it); `libjnigraphics` x1; `libringrtc_rffi` x1 (in-APK).

## The 57 gaps, classified

### Free (~15) - provided by QNX, just stage/link
`accept bind connect socket setsockopt getsockopt getsockname getpeername
listen shutdown recvfrom recvmsg sendto getaddrinfo freeaddrinfo` - QNX puts
sockets in **libsocket.so.3**, not libc. `gettid` is in QNX libc.so.3 already.

### Easy shims (~20)
- FORTIFY: `__read_chk __FD_CLR_chk __FD_ISSET_chk __FD_SET_chk`
- bionic helpers: `__cmsg_nxthdr __gnu_strerror_r __ctype_get_mb_cur_max
  android_set_abort_message __register_atfork`
- `OPENSSL_memory_alloc/free/get_size` (malloc wrappers)
- `stdin stdout stderr` data symbols
- locale: `newlocale uselocale freelocale strftime_l mbsnrtowcs wcsnrtombs`
  (collapse to C-locale versions)
- `getrandom` (read /dev/urandom), `madvise` (no-op)

### Real Linux features (~10) - the actual work
- **epoll**: `epoll_create epoll_create1 epoll_ctl epoll_wait` (ringrtc_rffi,
  signal_jni) - poll-based shim for small fd sets
- **eventfd** (signal_jni) - pipe-based shim
- **prctl** (ringrtc x2, signal_jni) - subset (PR_SET_NAME etc.)
- **mremap** (sqlcipher) - mmap+memcpy shim
- **syscall** (8 libs!) - THE risk: generic Linux syscall trampoline. `futex`
  is never referenced directly (0 libs), so futex/epoll extras go through
  `syscall`. Next: disassemble the call sites and enumerate the syscall
  numbers actually used; shim those individually.
- **dl_iterate_phdr** (Rust unwinding in ringrtc_rffi/signal_jni) - implement
  over the QNX loader's r_debug list, or Rust panics unwind badly.

### My compositor's job (10) - aligned with A8
`ANativeWindow_*` x8 (image_processing, surface_util) +
`AndroidBitmap_lockPixels/unlockPixels` (jnigraphics) - implement over the
facade framebuffer. Stub first (black video), real impl when calls matter.

## Per-lib gap counts

libringrtc_rffi 39, libsignal_jni 25, libimage_processing_util_jni 8,
libconscrypt_jni 7, libsurface_util_jni 6, libsqlcipher 6, libringrtc 4,
libmobilecoin 2, libaesgcm 2, libnative-utils 1, datastore_shared_counter 0,
androidx.graphics.path 0.

## Follow-ups

- NOD-18: the shim layer (epoll/eventfd/prctl/mremap/locale/chk/OPENSSL-mem +
  the `syscall` site audit). Gates Signal (NOD-14).
- ANativeWindow/AndroidBitmap fold into the facade work (A8+).
- Raw outputs (per-lib undef/needed/final lists, platform.def) regenerate from
  the APK; not committed.
