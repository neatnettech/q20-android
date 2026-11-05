# Architecture direction: Android-on-QNX, not a pure-QNX userland

Decision taken 2026-11-05, after the Signal gap probe (NOD-16).

## Question

Leverage QNX entirely as the OS (treat it as "a Linux already running") and
strip everything BB, versus the original direction: Android (ART + framework)
ported onto QNX.

## Decision

**Android-on-QNX, with a native QNX shell.** The facade/compositor owns the
panel (pure QNX, root); Android runs as the app engine inside it.

## Why

- **QNX is not a Linux.** No Linux syscall ABI (no epoll/futex/eventfd/
  namespaces/seccomp/cgroups). The Signal probe measured that wall: 57 gaps
  for one app. A pure-QNX userland makes the same wall apply to *everything*.
- **"Strip BB" splits into layers.** Cloud/services (Hub/BBID/telemetry/
  Amazon): strip - that is NOD-12/15. UI shell (Navigator): already stripped -
  the facade owns Screen. Platform/drivers (Screen, PPS, radio daemons,
  camera, audio, KGSL): **cannot strip - they ARE the hardware enablement**;
  they are userland resmgrs, not a kernel that survives the purge.
- **Pure-QNX means becoming the OS vendor for everything above the drivers**:
  UI toolkit plus every app from scratch. Signal becomes a protocol
  reimplementation (libsignal-client in Rust; Rust has no QNX 6.6 ARMv7
  target, and unofficial clients on Signal production are ToS-gray).
- **The security ceiling does not move.** Same frozen QNX 6.6 kernel, same
  BB-held boot keys, same no-TEE: "posture, not guarantees"
  ([security-feasibility.md](security-feasibility.md)) either way. Paying the
  app-ecosystem price buys nothing on assurance.
- **The synthesis is the current architecture anyway**: native QNX shell +
  daemons + resmgr-level enforcement; BB platform kept as drivers, BB cloud
  removed; Android as the contained app runtime. Native where native wins
  (telephony bridge to the radio daemons = NOD-13).

## Where the clean-slate OS energy belongs

**q20-reborn** (new hardware): there the base is **mainline Linux, not QNX** -
QNX is proprietary (BB royalties on a shipped product), mainline has the
QCS8550 drivers for free, and owning the hardware finally means owning the
boot chain (real verified boot). On the Q20, QNX is the immutable substrate
we exploit; on reborn, we choose the substrate.
