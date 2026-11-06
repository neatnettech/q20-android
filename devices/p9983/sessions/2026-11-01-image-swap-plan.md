# Session 2026-11-01 — P'9983: still hanging at "Verifying and securing device"

Re-flashed the same pre-rooted image; same hang. User's two new threads:

1. **Get a reference from booting the working device** — watch the USB PID
   timeline during boot (Classic as the reference, P'9983 to compare).
2. **Swap the image to one that fits the device** — RULED OUT (see below).

## Facts gathered

- **Image-swap ruled out (user's byte-level comparison)**: the SQK100
  autoloaders that exist (10.3.1.997 / 10.3.2.159, nothing newer) are
  byte-identical in payload to the SQN100 builds of the same version —
  same PE stub, same containers, only a 4-byte difference in a scrambled
  name table. CrackBerry: the P'9983's official 10.3.3 autoloaders
  (2205/3216) are "totally the same" as the Q10 ones; the PD clock/theme
  was an add-on, not a different OS. => The Q10 10.3.3.498 build we
  flashed IS the P'9983 image. The hang is not a model/variant rejection.
  The 10.3.2.159 download (partial, 1.4 GB) was deleted.
- The watermark on the screen is therefore either the proto-unit marker
  (label says SQM100-2) or a symptom of the failed first boot — not an
  image-fit signal.
- The Classic is reachable on 192.168.1.184:2225 (ssh needs the legacy
  algos: `-o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa
  -o KexAlgorithms=+diffie-hellman-group14-sha1 -c aes128-ctr -m hmac-sha1`).
  Reference eMMC layout captured: user0 on `/` (27.9M blocks), os1t179 on
  /base, radio0t17 on /radio, uda0 30.7M blocks.

## Reframed plan (image is fine => the injection or the device state)

## FLASH RESULT 2026-11-01 (evening): stock boots to the wizard — the hang is enrollment

- Stock flash (ifs+os+radio, no injection) all Complete 40C0. Boot timeline:
  8001 → off-bus → 8017 at +212s, stable 8017 for 15 min (OS healthy).
- Stock reaches the setup wizard: EULA → SIM/WiFi step (NO offline-skip
  path, only "Previous") → connect → "Verifying and securing device" = the
  **BlackBerry Infrastructure enrollment + device cert verify** step, and it
  hangs there. On 10.3.3 with the BB infra dead (2026), the verify either
  hangs forever (DNS resolves, dead server) or fails (if DNS blackholed).
- Implication: the 10-31 pre-rooted hangs were THIS step, not the
  injections — the sz-job suspect and the whole injection-bisect theory are
  dead. The wizard-skip flag was likely working all along.
- The watermark: still present on stock (per user) => permanent unit
  marker (proto SQM100-2), unrelated to image or hang.

## Escape paths (user's plan)

A. **Fail-fast DNS blackhole**: make *.blackberry.com / *.rim.net /
   *.bbprotect.* resolve to nothing (NXDOMAIN or 0.0.0.0) so enrollment
   fails quickly and the wizard offers continue/skip. Via FibreBox admin
   blocking, pihole, laptop hotspot, or the Mac as LAN DNS blackhole
   (pfctl redirect to a local forwarder). — user declined (no wifi bs),
   went straight to the image route.
B. **Wait it out**: 20-30 min untouched at the hang; some units
   auto-continue.

## THE IMAGE ROUTE — BUILT AND FLASHED (2026-11-01 evening)

The wizard-skip = `/var/pps/services/firstlaunch/status_public` with
`@status_public\ninprogress::0` — recovered byte-exact from the Classic's
working bake (OS.signed.unsigned, still on disk). It was NOT discredited
by the 10-31 hangs: those were the enrollment step hanging on the dead
BlackBerry infra (DNS resolves, server dead).

### Tools built (all in tools/flash/)

- `qcfm_unpack_streams.py` — unpack os.signed into rcfs/sig2/mbr/ufs.
- `qnx6_inspect.py` — QNX6 reader (BB10 variant, magic 0x97E6EEDD, sb
  @0x2000, crc32_be over sb[8:512], data @0x3000, 4K blocks; Inode/Bitmap/
  Longfile = indirection files: inode L1@25025 -> L2@25000..25024 -> data
  (identity for the first blocks); bitmap L1@25493 -> data@25026;
  longfile L1@436818 -> data@436823; dir entries 32B [ino:4][len:1][name:27]).
- `qnx6_wizskip.py` — injects /var/pps/services/firstlaunch/ +
  status_public (inode 34837/8, blocks 441797/8, nlink fixes, sb free
  counts + checksum). bb10mt `qnx6 fsck` = CLEAN on the result.
- `usb_timeline.py` — 0fca PID timeline logger (the boot reference).

### The flash lesson (burned us once)

The container MUST carry the stock's full 560-byte trailer ("QNXH-OS-1"
32B header + 528B seal). Without the header, bblink's strip_seal misses
the seal -> the seal streams as data + a dummy signature goes out ->
Complete 4015 (reject) + the loader WEDGES for ~10 min (rollback) ->
recover via the bootrom ritual + a clean radio re-flash (4006). WITH the
trailer: signature 4006 + Complete 402E = the documented "rcfs commit
rejected, the User stream lands" outcome (docs/common/flash-lane.md).

### Flashed + booted — but the wizard STILL appeared

Flashed ifs + os-wizskip (sig 4006, Complete 402E) + radio (4006).
Boot: 8001 -> bootrom retries -> 8017 (+199s) -> **the setup wizard ran
anyway**. So the status_public/inprogress::0 flag — proven on the Classic
(10.3.3.3216) — does NOT skip the OOBE on the Q10 10.3.3.498 build.
Either the Q10's firstlaunch ignores the persisted object, or the skip
needs more of the Classic's bake (the getroot package / a different
marker).

### Next session

1. RE the Q10 OOBE skip condition: `devices/p9983/oobe-re/` has
   oobe-service + libOOBE.so pulled from the Classic (the same firstlaunch
   binaries) — find what seeds `inprogress` and what a skip requires on
   10.3.3.498 (compare with the Classic's live /var + /pps state).
2. OR just pass the wizard on-device: option B (leave it 20-30 min at the
   enrollment step — never actually tried) or option A (blackhole DNS so
   the enrollment fails fast and the wizard offers continue/skip).
3. Once the home screen is reached: Dev Mode (<device_password>) -> WiFi ->
   chain.sh — the proven Classic flow, /q helpers on the first boot.





## Update: there is no P'9983 specific image, and none is needed

* archive.org has SQK100 builds only for 10.3.1.997 and 10.3.2.159. No
  SQK100 10.3.3 build exists there. CrackBerry owners went to 10.3.3 with
  the Q10 autoloaders (10.3.3.2205, 10.3.3.3216); BlackBerry never shipped
  a separate P'9983 10.3.3 payload. The PD clock and theme were lost on
  that path, so the PD skin was an add on, not a different OS.
* Proved for 10.3.2.159 with HTTP Range requests (no full download):
  `Autoload-SQK100-1` and `Autoload-SQN100-1` have a byte identical PE stub.
  The only difference is the obfuscated name prefix before the ver2 sig
  (SQK 0x34 bytes, SQN 0x30), which shifts every container offset by 4.
  After that shift the first 10 MB match exactly, 1 MB at the start of
  containers 2 and 3 match, and the last 1 MB matches. Same signed
  containers, different label.
* So the Q10 10.3.3.498 image already on the device IS the P'9983 10.3.3
  image. Image fit does not explain the hang. The 10.3.2.159 download was
  stopped at 1.17 GB (partial file kept); do not flash it, since it carries
  the same payload and the downgrade gate may refuse it.
* Next: step 5 above (stock, uninjected Q10 os.signed, watched with
  usb_timeline.py) is now the main experiment.

## Resolved 2026-11-06

The marker was wrong, not the build: the navigator's
`/var/pps/system/navigator/config` `autorun::1` is what launches the OOBE, and
`status_public` is not consulted for it. Both user partitions are the same
template at `10.3.3.746`. See
[2026-11-06-oobe-autorun-root-cause.md](2026-11-06-oobe-autorun-root-cause.md).
