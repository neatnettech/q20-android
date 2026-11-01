# Security feasibility: Android and GrapheneOS features on BB10/QNX

Assessment written 2026-11-01, after persistent root and A7 compositing.

## The vision

Security comes before the app build up:

1. Strip Google services, the Amazon Appstore and the phone home BB services.
2. Build a hardened, GrapheneOS like base.
3. Replace the BB native services with my own.
4. Signal is the first real world app on the hardened stack.

## The core fact

Most Android and GrapheneOS security is enforced by the **Linux kernel**: SELinux,
seccomp, namespaces, dm-verity, fscrypt, eBPF (netd) and cgroups. None of it exists on
QNX. Only the framework layer comes along with the ART port.

Everything on the kernel side has to be **re-expressed** in QNX primitives, not ported:

* procmgr abilities
* Pathtrust (exec trust by dev/ino, see [trusted-inode.md](trusted-inode.md))
* uid/gid
* permission checks inside each resource manager. QNX is a microkernel, so enforcement
  lives in the resmgrs. There is no equivalent of a syscall filter.

## Feature map

| Feature | Verdict | Route |
|---|---|---|
| No GMS | free | AOSP 6.0.1 has none; my stack never had it |
| No Amazon Appstore | free | it lives in the BB factory 4.3 runtime (sys.android BAR), not in my stack; never start the factory runtime |
| Kill BB phone home (QNX side) | medium, very doable | with root: inventory running processes, sockets, launcher and PPS jobs, Hub/push/BBID/telemetry daemons; disable through pps/launcher config; verify with a packet capture. Most BB infrastructure is dead, but the retries still leak identifiers (IMEI, PIN) |
| Android permission model, uid per app | medium | framework (PackageManager, ActivityManager) on ART plus a uid per app; README Phase 4/5 |
| App sandbox | hard, with precedent | the factory libbionic already exports `defineAppSandbox`, `checkAppCapabilities`, `dropWriteAndExecSystemCapabilities` (README Phase 4); reuse it or reimplement on abilities plus Pathtrust |
| Network permission toggle (GrapheneOS) | medium | no eBPF; enforce in io-pkt (check whether pf is present) or in the socket layer per uid |
| Sensor and storage scopes | medium | framework side plus resmgr permissions on device nodes |
| Hardened allocator | easy to medium | hardened_malloc is 64 bit only and the Q20 is ARMv7 32 bit; use Scudo (32 bit capable) in my bionic |
| Exploit mitigations | partial | ASLR and NX: check what QNX 6.6 provides. MTE, PAC, BTI: impossible on ARMv7 |
| Storage encryption | reuse | BB10 device encryption exists; there is no fscrypt. Keep BB's, do not port |
| Hardware keystore / TEE | very hard, likely blocked | QSEE trustlets are signed by BB/Qualcomm. Software keystore only, unless the factory runtime exposes a BB keystore bridge (check q20-runtime) |
| Verified boot I own | impossible | BB holds the signing keys. The root chain itself proves the boot integrity is not mine |
| Security patches | hard ceiling | the QNX 6.6 kernel is frozen since BB10 end of life; the Android 6 framework is from 2015 (selective backports, README Phase 7) |

## The honest ceiling

Reachable: a debloated stack with no phone home, apps sandboxed per uid and gated by
permissions. That is the GrapheneOS **posture**, not the GrapheneOS **guarantees**. An
unowned boot chain, an unpatched kernel, no TEE control and a 32 bit SoC cap the
assurance. Real high assurance belongs to the `q20-reborn` hardware track.

### My own back door

The kill-proof root sshd (port 2225), the trusted inode payload and the self healing
installer jobs ([root-chain.md](root-chain.md)) together form a textbook persistent
implant. That is fine for development. A hardened build must ship with it disabled or
gated: key only, off by default, with a documented re-arm path.

## Signal risks (check early)

* Signal's current minSdk: if it rises above 23, Android 6 is out.
* It works without FCM (websocket fallback), so no GMS is needed.
* Its native libraries (`libsignal_jni.so`, RingRTC/WebRTC, SQLCipher) are Linux bionic
  ELF that use epoll, futex, eventfd and other Linux syscalls. They must load against my
  QNX bionic glue. This is the biggest unknown; test it **before** investing in the
  framework.

## First slice (read only, cheap, high information)

1. **Phone home inventory** over root SSH: `pidin`, the socket list, the launcher and pps
   job lists, DNS lookups while idle (capture at the Wi-Fi AP). Record per entry:
   process, endpoint, how to kill it.
2. **Signal native lib probe**: pull the Signal APK, list the undefined symbols of its
   arm .so files (`readelf`/`nm`) and diff them against the symbols my bionic exports.
3. **Threat model**: the ceiling above plus the root door policy.
4. Then the Phase 4 sandbox probes as already planned in the README.

No porting code until the inventory and the Signal gap list show real targets.

## Done when

* After disabling, a 24 hour idle packet capture shows zero BB endpoints.
* Every undefined symbol in Signal's native libraries is either resolved or listed as a gap.
