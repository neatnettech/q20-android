# The token wall and device access: full session record

Goal of this thread: get the Q20 to run an app in the app-launch context
(installed + launched by the system) so the A7 compositing question can be
answered. Every install path was tried. This is the record.

## The conclusion so far

* BB10 composites only windows of registered apps; a bare devuser process
  creates windows (CPU-mappable 720x720 buffer, post succeeds) but nothing
  renders.
* All install paths funnel into one wall: BlackBerry 10.3.3 requires apps
  signed with a device debug token. Tokens are unobtainable (RIM servers
  dead). The factory Android runtime refuses every APK, including its own
  Calculator.apk, with "unable to install this app".
* The breakthrough of the session: adbd listens on TCP 5555 and adb works.
  This gives a shell inside the factory Android 4.3 runtime, where `pm`,
  `am`, logcat and the package database live. That is the current attack
  surface for bypassing the token gate.
* The dev-mode door (port 4455, the thing Connect.jar speaks) is the other
  surface: its protocol is fully understood at the framing level now, and it
  has a START_SERVICES action that nobody has driven yet.

## 1. BAR install attempts

* Files app, tap .bar: "Unable to open" (10.3.3 has no local .bar handler).
* Browser download of a .bar served over the USB link
  (169.254.0.2:8000, Content-Type application/vnd.rim.bar): downloads fine,
  no install prompt. 10.3.3 has no browser .bar install hook.
* BarDeploy.jar 1.3.0 (PlayBook SDK) against the device: "peer not
  authenticated". See section 4 for why.
* BAR packaging works: hand-rolled dev-mode BAR with BarPackager.jar 1.4.3.
  Field formats copied from the factory sys.android MANIFEST.MF
  (Archive-Manifest-Version 1.1, base64-style Package/Application-Ids,
  88-char SHA-512 author-certificate hash, Entry-Point-Key e1,
  Entry-Point-System-Actions run_native, Application-Development-Mode true).
  Packager verifies it. The BAR itself is fine; the install path is the wall.

## 2. APK install attempts

* The Q20 user-visible storage is /accounts/1000/shared (books, camera,
  documents, downloads, ...). It is NOT the Android /sdcard (that is a
  separate tree with its own Download dir). The browser that downloaded our
  .bar files was the BB10 browser, writing into BB10 shared storage.
* Factory Android runtime lives at
  /accounts/1000/appdata/sys.android.gYABgKAOw1czN6neiAT72SGO.ns/
  (uid 1000 owned, not readable by devuser).
* PackageInstaller UI (unknown sources enabled, verify-apps disabled):
  "unable to install this app" for our API 18 APK AND for the factory's own
  Calculator.apk. That rules out our APK: it is BlackBerry's token gate.
  Rebuilt q20prober.apk for minSdk 18 (the runtime is Android 4.3, API 18).

## 3. The root route (research repo)

* stanw47's Classic root: getroot's btool (a sh script) runs as root at
  boot via /base/scripts/ota_info_pps.sh, whitelists /base/bin/__root with
  /proc/boot/pathtrust, and __root's setuid then works.
* Our device is stock: ota_info_pps.sh is the original root-owned 6373 byte
  script (not the btool symlink), no __root, no sud, no getroot install.
* qsh.py/qpull.py from the research repo require __root already present,
  so they are circular for us.
* The original getroot installation vehicle is the dev-mode door itself
  (the 4455 service runs as root). That is why section 4 matters.

## 4. The dev-mode door, protocol archaeology

* Connect.jar (2 KB) is a thin client of jqconnDoor.jar: RTAS framing +
  ECC auth (EccpressoAll.jar) + password authentication. Target codes:
  HELLO, FEEDBACK, START_REQUEST, ENCRYPTED/DECRYPTED_CHALLENGE_RESPONSE,
  KEEP_ALIVE, SEND_SSH_KEY, AUTHENTICATE_CHALLENGE_REQUEST/RESPONSE,
  AUTHENTICATE, START_SERVICES, CLOSE.
* The shipped client has actions only for the SSH key push. No shell/exec
  action exists in the client classes. START_SERVICES is implemented in the
  client (SecureTargetStartServices.class) but nothing calls it: it is the
  untried door that likely starts the dev tool services on the device.
* The OLD dev tool protocol (BarDeploy) is HTTPS to the DEVICE port 443 with
  CGI endpoints (/cgi-bin/login.cgi, /cgi-bin/appInstaller.cgi). Its client
  trusts every server certificate (no-op X509TrustManager) and sends no
  client certificate (null KeyManagers), so the "peer not authenticated"
  failure is a TLS protocol/version/cipher problem, not a trust problem.
* TLS archaeology: OpenSSL 3, LibreSSL (macOS Python) and JDK 17 all fail
  the handshake (server sends handshake_failure). JDK 17 with TLSv1.0
  re-enabled (jdk.tls.disabledAlgorithms and jdk.tls.legacyAlgorithms
  cleared, https.protocols=TLSv1) still fails. The device carries a static
  ECC root key at /var/bp2p/ecRootKey.pem (ecRootCert.pem), and the likely
  requirement is a static-ECDH cipher suite (TLS_ECDH_ECDSA_*, matching the
  Eccpresso crypto), which SunJSSE does not implement. JDK 8 has no bottle
  for this host (source build only). The device cert was pulled into a
  truststore but the handshake never gets to certificate exchange.
* Device listening ports: 22 (sshd), 80, 443 (devtool HTTPS), 4455 (door),
  5555 (adbd), 8443 (unknown, likely another devtool endpoint).

## 5. The adb breakthrough (current state)

* adb connect 169.254.0.1:5555 works (adbd on the device, first try).
* adb shell is the factory Android 4.3 (API 18) shell. Very limited toybox
  (no grep, no id). Each adb shell command prints its output but the shell
  session then hangs (adb waits past the command end); use one-shot commands
  with short timeouts.
* The Android /sdcard exists separately (Alarms, Android, DCIM, Download,
  ...). adb push works into it.
* adb install of q20prober.apk hangs (no result in 5 minutes).
* pm list packages / pm install also hang; logcat via adb shell hangs too.
  The package manager service is either extremely slow or wedged; the next
  step is to get logcat out reliably (try redirect on-device to a file then
  adb pull) and read the INSTALL_FAILED reason.

## 6. Next steps, in order

1. Recover the pm install error: `adb shell "logcat -d > /sdcard/Download/lc.txt"`,
   then adb pull lc.txt. If logcat is wedged, read /data/system/packages.xml
   and dmesg equivalents.
2. If the token gate rejects pm installs, use the Android-side shell to
   bypass it: its uid and the files it can touch (package DB, /data/app,
   the runtime's own libs) are the surface. Patching the factory runtime's
   package manager or pre-seeding its DB are both on the table now that a
   shell exists inside it.
3. Drive the door's START_SERVICES action (small Java harness against the
   SDK jars, JDK 26 compatible) and see what starts (port 8443 candidate).
4. Revisit the devtool HTTPS with a static-ECDH-capable TLS stack only if
   2 and 3 dead-end.

Artifacts from this session: runtime/qnx-shims/screen_probe.c (drawing
probe, links /base/usr/lib/libscreen.so), /tmp/bar (BAR build, manifest,
screenprobe.bar, jarsigner keystore), toolchains/android-tools (aapt2, d8,
android-23.jar), q20prober.apk rebuilt for minSdk 18.

## 7. The wall dissolved: it was never a RIM token (2026-10-01)

adb on 5555 gave a stable shell today (`exec-out` unsupported on 4.3 adbd;
`adb shell` wedges after each command, so write output to
`/sdcard/Download/*.txt` on device and `adb pull` it). Reading the actual
install logs overturns the token-gate thesis. Three independent, mundane
failures were being read as one crypto wall:

1. **Factory Calculator.apk re-install = INSTALL_FAILED_DEXOPT (-11).**
   `DexOptZ: zip archive does not include classes.dex`, status 0xff00,
   `QNXInstallerService: Install failure [-11]`. The factory APKs are
   odex-only (classes.dex stripped). Nothing to do with signing.
2. **adb/pm install = denied INSTALL_PACKAGES.** `pm`/`adb install` run as
   uid 2000 (shell) and die in `installPackageWithVerificationAndEncryption`
   with `SecurityException: Neither user 2000 nor current process has
   android.permission.INSTALL_PACKAGES`, before any signature is examined.
   A plain Android permission RIM left off the shell uid, not a token.
3. **Our own APK via the PackageInstaller UI** (launched with
   `am start -a android.intent.action.VIEW -d file://... -t
   application/vnd.android.package-archive`, which runs PackageInstaller as
   its own uid 10128, a process that does hold INSTALL_PACKAGES):
   * First our APK was **unsigned** (no META-INF/*.RSA). 4.3 rejects that.
   * jarsigner from JDK 26 produced a signature 4.3's verifier refused:
     `SecurityException: Incorrect signature` at
     `PackageParser.collectManifestDigest`. Still not a RIM token, just a
     digest algorithm 4.3 does not accept.
   * **Fixed by signing with `apksigner` (build-tools 35) v1 scheme,
     `--min-sdk-version 18 --v1-signing-enabled true
     --v2-signing-enabled false`.** The APK then parses cleanly: no
     signature error, no SDK error (our manifest is minSdk 18; the earlier
     `Requires newer sdk version #19` lines were a stale cached push).

### The real, current blocker (precise)

With a correctly v1-signed APK the BB10 PackageInstaller gets all the way to:

```
I/PackageInstaller: Sending installation invoke
I/PackageInstaller: Installation invoke failed
```

BlackBerry rewired PackageInstaller: instead of calling
`PackageManager.installPackage`, it fires a **BB10 invoke** to hand the
install to the native installer (QNXInstallerService via navigator). That
invoke fails for a raw APK, which carries no BB10 package identity. So the
device installs Android apps only when they arrive as **BARs** through the
BB10 flow. This is architectural, not cryptographic.

### Why the direct PPS route is a dead end from the shell

`/pps/services/android/{control,query,shrimp}` are the installer trigger
objects and are `system:system` rw-rw----. The adb shell is uid 2000 and
cannot read or write them (`status` is world-readable and only reports
runtime state). Driving the collaborative install directly needs uid 1000
(system) or root, which a stock user build (`ro.secure=1`,
`ro.debuggable=0`, no su) does not give the shell.

### Where that leaves the three routes

* **A. Dev-mode BAR** (recommended for the factory-install goal). Wrap the
  signed APK in a development-mode BAR (the prior session already builds one
  with BarPackager 1.4.3, `Application-Development-Mode true`) so it carries
  the BB10 package identity the invoke needs. Dev mode is ON. The only open
  problem is transport: BarDeploy's TLS is a static-ECDH dead end, and 10.3.3
  has no local .bar handler, but SSH (22) and the dev door (4455) are both up
  and are the modern install transports to try next.
* **B. QNXInstallerService PPS** needs system/root first. Blocked from the
  uid-2000 shell.
* **C. Our own ART6** (the q20prober ladder, docs/apk-milestones.md) needs no
  factory install at all and stays the cleanest track.

### Signing recipe that works for 4.3

```
apksigner sign --ks <keystore> --ks-pass pass:<pw> --key-pass pass:<pw> \
  --min-sdk-version 18 --v1-signing-enabled true \
  --v2-signing-enabled false --v3-signing-enabled false app.apk
```

jarsigner from a modern JDK does NOT work: it disables SHA1 and emits a
digest 4.3 rejects as "Incorrect signature".

### adbd is fragile

`adb shell screencap` crashed adbd (port 5555 went from open to refused).
SSH (22) and the door (4455) stayed up. Avoid screencap over this adbd;
the Android runtime restarts adbd eventually, or toggle it from the device.

## 8. Transport solved end to end; the only wall left is the debug token (2026-10-01)

The dev-mode BAR install pipe now works completely, start to finish. Driving
BlackBerry's own `blackberry-deploy` (BarDeploy.jar) against the device:

```
Info: Sending request: Install and Launch
Info: Action: Install and Launch
Info: File size: 10236
Info: Installing ScreenProbe.gYAAgNno2qFNkmnKbfpdH3gCdjA...
Info: Processing 10236 bytes
result::failure 881 no debug token found
```

TLS, authentication with the device password, and the BAR upload all
succeeded. The install was refused only because no debug token is present.

### The "TLS dead end" was never real

The device install CGI on 443 speaks **TLSv1.0 / TLS_RSA_WITH_AES_256_CBC_SHA**
(static RSA, not static ECDH as section 4 guessed) with a legacy (SHA1,
small-RSA) certificate. Modern JDKs disable exactly those, so BarDeploy failed.
curl negotiates it fine, and so does JDK 17 once the disabled-algorithm lists
are emptied:

* `java.security` override, three empty lines:
  `jdk.tls.disabledAlgorithms=`, `jdk.certpath.disabledAlgorithms=`,
  `jdk.tls.legacyAlgorithms=`
* run with `-Djava.security.properties=<override>
  -Dhttps.protocols=TLSv1 -Djdk.tls.client.protocols=TLSv1`
* a tiny trust-all `TLSv1` HttpsURLConnection to
  `https://169.254.0.1:443/cgi-bin/login.cgi` returns `HTTP 200`.

So BarDeploy works verbatim under openjdk@17 plus that override. Port 80 also
answers; `/cgi-bin/discovery.cgi` returns full device info in plaintext with no
auth (PIN [redacted], platform 10.3.3.3216, DeveloperModeEnabled 1, screen
720x720).

### What the debug token actually gates

Error 881 is BlackBerry's dev-mode authorization: installing an author-signed
(non-store) BAR requires a debug token on the device. The token binds the
device PIN and the author key and is signed by BlackBerry's code-signing root,
which the OS verifies against a baked-in key. BlackBerry's signing server is
shut down, so a fresh RIM-signed token cannot be minted, and old tokens are
PIN-bound and expire in ~30 days. `DebugTokenRequest.jar` needs
EccpressoAll.jar on the classpath to run, but it only builds a request that the
dead server would have to sign.

### Where the factory-runtime app-install goal stands

Everything mechanical is solved: TLS, auth, upload, APK v1 signing, package
parsing (sections 7 and 8). The only remaining gate is the debug token
signature, and it is a real cryptographic wall because the signer is gone.

Honest options, for the owner to choose:
1. An existing valid debug token (almost certainly expired; dead end).
2. Root the device and relax or satisfy the on-device token check. This is the
   dev-mode door (4455, runs as root) / getroot route from the research repo.
   It is the dual-use path and is the owner's explicit call.
3. Skip the factory runtime entirely: our own ART6 runs the app under dalvikvm
   (docs/apk-milestones.md, A3 done), no BB10 install and no token involved.

### Device facts captured

PIN [redacted], author id gYAAgNno2qFNkmnKbfpdH3gCdjA, platform 10.3.3.3216,
screen 720x720, dev mode on. Ports: 22 ssh, 80 http (discovery.cgi open),
443 install CGI (reachable now), 4455 dev door, 5555 adbd (crashes on
screencap), 8443 unknown.

## 9. Root quest, session one: devuser tooling gained, root surface mapped (2026-10-01)

The owner chose the root route. Result so far: a new devuser-level execution
channel and a complete map of the root surface. Root itself is still behind
the obfuscated door daemon.

### Won: qconn on port 8000 (devuser command execution)

Port 8000 is the QNX qconn debug agent (telnet-ish framing, broker service
with prompts `<qconn-broker>` / `<qconn-launcher>` / file / cntl / sinfo).
Protocol reference: github.com/johnson-thomas/qnx8-qconn-mcp. A minimal
client now lives in runtime/qnx-shims/qconn_exec.py:

```
python3 qconn_exec.py "<shell command>"
service launcher + "start/flags run /bin/sh /bin/sh -c <cmd>"
```

It runs as DEVUSER (writes land as devuser, /root denied), so it duplicates
SSH, but it adds the qconn file service and process spawn without SSH and
will keep working when sshd is down. It is the stable tool for the next
sessions.

### Root surface, fully mapped and closed for devuser

* No setuid/setgid binaries in /base/bin.
* /base (os image) is read-only; the btool-era write to
  /base/scripts/ota_info_pps.sh is impossible on this firmware.
* /pps/system/development/devmode carries the token state
  (debug_token_installed:false, debug_token_validation_error:"no debug token
  found", error code 1) but is not writable by devuser; the installer PPS
  objects (/pps/system/installer/*) are not writable either.
* Port 80 serves only /cgi-bin/discovery.cgi (open, full device XML). The
  443 CGIs are login/appInstaller/file-transfer within the devuser sandbox;
  the install rejects with 881 no debug token found.
* Root SSH (root@ with the pushed key) is denied; the key authorizes devuser
  only. adbd on 5555 is flaky (dies after screencap/adb root attempts).
* The door daemon /base/bin/qconnDoor (34KB, stripped and string-obfuscated)
  imports posix_spawn* + setuid/seteuid + procmgr_ability + librtas (RTAS
  crypto) and libpps: it spawns the debug services with dropped credentials.
  The client library (jqconnDoor.jar) already sends START_SERVICES on every
  authenticated connect (Connect.jar does it), so the door has no further
  client-side actions to drive; whatever extra it can do is server-side.

### Remaining root paths, in order of tractability

1. RE the qconnDoor daemon (34KB, obfuscation is light: the import list and
   the spawn path are the targets). Question: are the spawned credentials
   fixed (devuser) or read from a PPS object we have not found? Binary is
   saved at runtime/qnx-shims/qconnDoor.bin (gitignored).
2. The factory Android side via adb (when adbd is up): its /data, package
   DB, and the runtime's own helpers (btool references
   /apps/sys.android.../native/system/bin/r, a root helper inside the
   runtime). The Android environment is a second attack surface.
3. The devtool HTTPS backends: identify the daemon behind 443 (search the
   device for the "no debug token found" string in jars and non-obfuscated
   services) and check whether its token store path is devuser-reachable.
4. QNX 6.6 kernel/procmgr exploit research (long).

Next session starts with (1): disassemble qconnDoor, find the service spawn
and its credential source.

## 10. The compositor gate re-examined: A4 tested CREATE, not JOIN (2026-10-20)

Re-reading `runtime/qnx-shims/screen_probe.c` against the BB10 windowing model
shows A4's negative result was over-interpreted. The probe called
`screen_create_window_group(win, "q20probe-group")` (screen_probe.c:47): it
made itself the **parent** of a brand-new group the Navigator has never heard
of. On BB10 the Navigator is the window manager that actually composites app
windows, and it composites the groups **it** owns. An app does the opposite of
what the probe did: it **joins** a group the Navigator already manages
(`screen_join_window_group`), and rides the Navigator's compositing of that
group.

So "bare process windows never composite" is explained by the self-created,
Navigator-unknown group alone. It is **not** evidence of a signing or root
gate on compositing. The app-launch/BAR/token conclusion was reached a rung
early: the JOIN path was never tested, and it needs no root to try.

What the model predicts (confidence: Likely for the mechanism, Guessing for
whether 10.3.3 lets a non-launched devuser process join a foreign group):

1. A window joined to the **live foreground** group the Navigator is already
   drawing should be composited as a child, no privilege change.
2. If joining a foreign group is denied, the next question is whether devuser
   can obtain a `SCREEN_WINDOW_MANAGER_CONTEXT` (force-composite route). EPERM
   there means that specific route is root-gated; it does not close path 1.
3. Only if both fail cleanly is "A7 needs app-launch/root" actually earned.

### Experiments, in order (all devuser, no root, run on the owned device)

1. `runtime/qnx-shims/nav_recon.sh` — zero build. Dumps the Navigator PPS
   registry (`/pps/services/navigator/*`), the foreground app's window-group
   name, and this process's (absent) windowing environment. Run it first: the
   live group name is the input to the probe. Drive it over the existing qconn
   channel (`qconn_exec.py`) or `q20ssh`.
2. `runtime/qnx-shims/navigator_probe.c` — links the device's own
   `/base/usr/lib/libscreen.so`, same build line as screen_probe. It (a) sweeps
   the four Screen context types and logs which the kernel grants devuser, then
   (b) `navigator_probe join <GROUP>` creates an app window and JOINS the group
   nav_recon found, fills solid magenta, posts, holds 60s. Magenta on the panel
   = A7 display route open without root. `navigator_probe` with no args
   reproduces the A4 CREATE baseline for comparison.

This is the productive, device-reachable half of the display work. The root
track (qconnDoor RE, section 9) is unchanged and remains gated on the saved
binary + device, i.e. a session with the hardware attached.

## 11. The experiments, run (2026-10-20, device attached)

Both experiments from section 10 ran on the phone over `q20ssh`. The results
narrow the A7 display route to one remaining variant, and they close two
routes for good.

### What the privilege sweep says

`navigator_probe` with no arguments, as devuser:

```text
=== context privilege sweep (devuser)
  APPLICATION      rc=0  errno=0 (granted)
  WINDOW_MANAGER   rc=-1 errno=1 (Operation not permitted)
  DISPLAY_MANAGER  rc=-1 errno=1 (Operation not permitted)
  INPUT_PROVIDER   rc=-1 errno=1 (Operation not permitted)
```

So **devuser cannot be the compositor.** Section 10's experiment 2 is
answered: the force composite route is privilege gated, exactly as predicted,
and it does not become available by trying harder. Owning the presentation
layer ourselves (the facade charter end state) needs root or a different
process identity, not a cleverer Screen call.

The CREATE baseline reproduced A4 exactly: group created, `USAGE WRITE|NATIVE`
accepted, display 0 attached, CPU mapped 720x720 buffer at stride 2944,
magenta filled, `screen_post_window` and `screen_flush_context` both rc=0, and
nothing on the panel. One new detail: the probe set `SCREEN_PROPERTY_ZORDER`
to 200 and the window read back `zorder=0`. The z order we ask for is not the
z order we get, which is consistent with a window whose group no compositor
owns.

### What the recon says

`nav_recon.sh` dumped the live Navigator state. The useful parts:

* `/pps/services/navigator/state` is world readable and names the Navigator's
  own z order, `navzorder:n:100`. Anything meant to land above the homescreen
  has to beat that, which is why the probe's z order is now a knob
  (`navigator_probe <mode> <GROUP> <Z>`, default 200).
* The per app `rundata_*` objects are world readable, and they carry
  `window_id`, which is the group handle we need. **Every one of them was
  empty or `none`**, because the phone was locked: `state` also showed
  `isDeviceLocked::passwordLocked`, `curr_window::none` and `windows_size:n:0`.
  Nothing was in the foreground to join.
* `/pps/services/navigator/windowgroup` and `/pps/system/navigator/groups` are
  **not readable** by devuser (`apps:nto`). The authoritative group registry
  is closed to us.
* `/pps/services/window_manager` and `/pps/services/screen` do not exist on
  this build.

### The env leak is closed too

On BB10 the Navigator mints the group name and hands it to the app it launches
through its environment, which is why a bare SSH process has no windowing
environment at all (the recon confirms that). Reading it out of a launched app
instead does not work either: devuser cannot open any other process's
address space.

```text
$ pidin -F "%b %N"
couldn't open /proc/1/as: Operation not permitted
couldn't open /proc/15196162/as: Operation not permitted
... every pid, same answer
```

### What is left

One variant, and it is still untried for a mundane reason: **the phone was
locked**. With the device unlocked and an app in the foreground, that app's
world readable `rundata_*` should publish a real `window_id`, and that is a
group name to try:

```sh
runtime/art-qnx/device/q20ssh 'cat /pps/services/navigator/state'          # curr_window
runtime/art-qnx/device/q20ssh 'cat /pps/services/navigator/rundata_<app>'  # window_id
runtime/art-qnx/device/q20ssh 'cd /accounts/devuser && ./navigator_probe join <GROUP> 200'
```

If a joined child window does composite, A7's display route is open with no
root. If the join is refused, the display half of A7 is genuinely gated on
root or the app launch path, and the qconnDoor track (section 9) becomes the
critical path for pixels.

Either way the *drawing* half of A7 no longer waits on this: the facade
renders the real View tree through its own Canvas JNI into the window buffer,
and `Q20_DRAW_PNG` writes the same frame to a PNG when Screen gives us no
composited window. A missing compositor now costs us the panel, not the proof.

### Probe builds

Both probes now build from the checked in Makefile instead of a remembered
command line, and link the dynamic sysroot `libscreen` with `/base/usr/lib`
baked as the runtime path, which is what the working A4 binary did:

```sh
docker compose run --rm --entrypoint /bin/bash aosp6 -c \
  '. toolchains/playbook-gcc9/env.sh && make -C runtime/qnx-shims probes'
```

`nav_recon.sh` also lost its last section: it opened
`/pps/services/navigator/control?wait`, and a `?wait` open blocks until the
object changes, which never happens on a locked idle device. It reads `state`
now.

## 12. The JOIN route is closed (2026-10-20, device unlocked, owner watching)

Section 10 set the bar for calling the display question settled: "Only if both
fail cleanly is A7 needs app-launch/root actually earned." Both have now
failed cleanly, on an unlocked phone with an app in the foreground and the
owner watching the panel.

### The foreground group was found, and it was the right one

With the device unlocked and the File Manager open,
`/pps/services/navigator/state` gives the live group directly:

```text
[n]curr_window::sys.perimeterbrowser.gYABgMgpl40MVrFkZvPEXRuQTGE
[n]windows_size:n:1
```

`sys.perimeterbrowser` is the File Manager. So `curr_window` is the group name
source we were missing in section 11, and `window_id` in the per app
`rundata_*` is empty even for the live fullscreen app, on this build.

### screen_join_window_group lies

It returns rc=0 for any string, including a deliberately bogus one:

```text
JOIN group "sys.perimeterbrowser.gYABgMgpl40MVrFkZvPEXRuQTGE" rc=0 (joined)
JOIN group "42672382"                                        rc=0 (joined)
JOIN group "sys.perimeterbrowser"                            rc=0 (joined)
```

The return value is worthless. What settles it is reading the membership back
after the post, and the control run proves the read itself works:

| path | `SCREEN_PROPERTY_GROUP` reads back | `BUFFER_SIZE` | on the panel |
|---|---|---|---|
| CREATE own group | `"q20probe-group"` | 720x720 | nothing (A4 baseline) |
| JOIN foreground group | `""` | 0x0 | nothing |

The joined window is in no group at all. The call is accepted at the API
boundary and dropped. The `0x0` buffer size is the same fact seen from the
other side: with no parent group there is nothing to inherit a size from.

### Two probe bugs that were hiding this

Both are fixed, and both mattered, because each one independently produces
"nothing on screen" for a reason that is not the compositor:

1. The probe filled `bdims[1]` rows using a `BUFFER_SIZE` read taken **before**
   allocation. For a joined window that read is `0x0`, so it filled zero rows
   and posted an unfilled buffer while printing "filled magenta". It now takes
   the size from the allocated buffer.
2. The probe never set `SCREEN_PROPERTY_SIZE`. A window that creates its own
   group inherits the display size; a joined one does not. It is set
   explicitly now (`NAV_SIZE`, default 720), and reads back 720x720 even on
   the joined window.

With both fixed the probe posts a genuinely filled, correctly sized 720x720
magenta buffer, `post` and `flush` both return 0, and the panel does not
change. Confirmed visually by the owner, twice.

### What this earns

* devuser gets a Screen `APPLICATION` context and nothing else (section 11).
* devuser cannot join a group it does not own.
* devuser cannot read the group registry, and cannot read any other process's
  environment to steal a name that would not work anyway.

So compositing requires either root (the `SCREEN_WINDOW_MANAGER_CONTEXT` that
the facade charter's "be the presentation layer" end state needs anyway) or
being launched by the Navigator (the app launch path, behind the dead debug
token servers of sections 1 to 8). The qconnDoor track in section 9 is now the
critical path for pixels on the panel.

This does not block the rest of A7 or the ladder above it: the drawing half is
done and verified on hardware (docs/bringup-log.md, A7 phase 2), and
`Q20_DRAW_PNG` reads every rendered frame back off the device without a
compositor.
