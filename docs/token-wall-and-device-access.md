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

## 13. Root quest, session two: the door's root branch is a client flag (2026-10-20)

Static RE of `runtime/qnx-shims/qconnDoor.bin` (34 KB, stripped ARM/Thumb-2,
analyzed with the toolchain's objdump/readelf in the container). The daemon is
far more legible than "string-obfuscated" suggested: the dynamic import table
plus the `.rodata` literals reconstruct the whole protocol. This is the
BlackBerry qconnDoor, the dev-mode door that provisions sshd/qconn, on an owned
Q20 running end-of-life 10.3.3.

### The daemon provisions sshd two ways, from the same binary

The `.rodata` carries both an sshd config for **root** and one for **devuser**,
at adjacent addresses, and the code picks between them line by line:

| line | root branch | devuser branch (what Connect.jar uses) |
|---|---|---|
| keyfile | `AuthorizedKeysFile=/var/qconndoor/.ssh/authorized_keys2` | `.../accounts/devuser/.ssh/authorized_keys2` |
| users | `AllowUsers=root` | `AllowUsers=devuser` |
| root login | `PermitRootLogin=yes` | `DenyUsers=root` |

All four `posix_spawn` sites in the binary call
`posix_spawnattr_setcred(attr, 0, 0)` first: every service the door spawns
(qconn, sshd) runs as uid 0. The devuser outcome we use today is not a
privilege ceiling in the spawn; it is the sshd config the devuser branch
writes.

### The branch is selected by a client-supplied field

The config-building function at `0x2f44` keys every choice above off one
boolean, a field at offset `0xf0` of the per-connection session struct
(`ldr.w r3, [r0, #0xf0]; cbz r3, <devuser>`). That field is written in the
command handler at `0x33c8`:

```
33c0  ldr   r3, [r4, #16]      ; session state
33c2  cmp   r3, #2             ; must be state 2 (authenticated)
33c4  bne   <error>
33c8  ldrh  r6, [sp, #64]      ; a 16-bit field from the client's request
33cc  mov   r9, #1
33d0  cbnz  r6, <devuser>      ; r6 != 0  -> devuser
33d2  str   r9, [r4, #0xf0]    ; r6 == 0  -> ROOT (flag = 1)
33d6  blx   RTAS_LoadQconnKeyExV2
```

So **root versus devuser is a client flag**: a 16-bit value in the
authenticated key-upload request, `0` for root. The session constructor at
`0x27c4` zeroes the flag, so devuser is only the default; the client chooses.
Connect.jar evidently sends a non-zero value. This is the heart of the finding:
the debug-token wall (sections 1 to 8) governs BAR/APK **installation**; it does
not gate this branch.

### What still has to be true, and the one unknown

The root branch is reachable only from session state 2, which is set after the
authentication challenge, and the auth is the **device password**, not a RIM
debug token: the challenge handler decodes `passwordExists` / `challenge` over
PPS and rejects with `Password not valid. Authentication failed` and `The
device password you provided is incorrect`. The owner has the password (it is
already what `connect.sh` feeds as `$BBPW`).

The root path does one extra thing the devuser path does not: at `0x33d6` it
calls `RTAS_LoadQconnKeyExV2`, and the challenge is checked by the QNX library
routine `VerifyEncryptionChallenge` (`0x349c`) against the loaded key. The open
question is purely **which key**: if the root branch verifies the challenge
against the RTAS **device-specific** key, a client needs the matching private
key (debug-token grade) and password alone is not enough; if it accepts the
password-derived challenge like the devuser branch, the password is enough. The
binary logs both `Using the device specific RTAS key %s` and `Using the
fallback RTAS key`, so the device-specific key is **not** a hard requirement at
load time: there is a fallback. Whether the fallback key also satisfies the
root-branch verify is the single thing static analysis cannot settle.

### The experiment that settles it (no new primitives, owner + device)

Drive the door protocol directly instead of through Connect.jar:

1. Open the qconndoor port over USB (wired is enforced: the daemon rejects
   non-wired with `Attempted to connect via non-wired connection`).
2. Complete the password challenge with the known device password, exactly as
   Connect.jar does, to reach session state 2. jqconnDoor.jar is the protocol
   reference; the wire format is the PPS-framed challenge above.
3. Send the key-upload command with the root selector `0` and our existing
   RSA-4096 public key, and watch for two outcomes:
   * sshd comes up with `PermitRootLogin=yes` and our key at
     `/var/qconndoor/.ssh/authorized_keys2` -> `ssh root@<ip>` works, root
     achieved, and A7 compositing (and the whole facade charter) unblocks.
   * the daemon rejects at `VerifyEncryptionChallenge` -> the root branch is
     bound to a device-specific key after all, and root stays behind the token;
     the finding then is a clean negative, not a guess.

Either way this is the next session's first action, and it is cheap: no new
crypto to break, just the protocol spoken correctly with the password we have.
The devuser channel (`q20ssh`, qconn 8000) is unaffected and stays the daily
tool.

## 14. Root quest, session three: the client confirms local password auth (2026-10-20)

Decompiled the vendor client (`Connect.jar` + `jqconnDoor.jar`, the
`blackberry-connect` tool, with javap) to settle section 13's open question
from the client side. It confirms the important half.

### Authentication is local and password-only, no RIM server

`AbstractSecureTargetConnection.authenticate()` runs the whole handshake
against a `LocalRTASConnection` (created by `ConnectionRegistry` whenever no
RTAS server setting is supplied, which is the default):

1. `SecureTargetChallengeRequest` with `rtas.getPublicEncryptionKey()` from the
   **local** RTAS object.
2. Target returns an encrypted challenge; the client decrypts it **locally**
   (`rtas.decrypt(challenge)`), logs `RTAS credentials verified.`, and returns a
   `SecureTargetDecryptedChallengeResponse`.
3. `SecureTargetAuthenticateChallengeRequest` -> target returns algorithm,
   iterations, salt, challenge.
4. `SecureTargetAuthenticate` carries `hashAndEncode(devicePassword, algo, salt,
   iterations, challenge)`: SHA1 or SHA512 of the device password with the
   salt, iterated, hex-encoded, then AES-wrapped with the session key.
5. `SecureTargetSendSSHKey`, then start services.

No network RTAS server and no debug token anywhere in the path. Identity is the
device password, which the owner has. This confirms, from the client side, that
the dead RIM infrastructure (sections 1 to 8) does not gate the door.

### The root selector is a client setting the stock tool pins to false

`TargetSetting` has a boolean `authenticateAsRoot` with
`setAuthenticateAsRoot` / `isAuthenticateAsRoot`. `Connect.createConnection`
calls `addTargetSetting(host, 4455, version, password, false)`: the stock tool
hardwires it **false**, and in this jar version no outgoing frame reads it, so
`blackberry-connect` can only ever provision devuser. Driving the daemon's root
branch (section 13) therefore needs a client that sets the flag and serializes
it into the frame the daemon reads, i.e. a small custom client built on the
jar's own frame and `LocalRTASConnection` classes, not the stock CLI.

### Harness and the one thing still unverified

A frame-logging TCP proxy (host `127.0.0.1:4455` -> device `4455`, since
`Connect.jar` hardcodes the port and takes only a host arg) captures the wire
format; the device still sees the USB peer, so the wired-connection check
holds. A first run captured the client HELLO (`len=6 ver=2 code=1`, empty
payload) before the device dropped off USB.

Still unverified, and it is the same single unknown as section 13: whether the
daemon's root branch accepts this local password auth or additionally binds the
challenge verify to the device-specific RTAS key. The next action is a custom
client with the selector set, run against the door, watching for sshd with
`PermitRootLogin=yes` versus a challenge rejection. It needs the device back on
USB (this session it disconnected: no ARP entry, all ports closed, host USB IP
fell back to a generic 169.254/16).

The research proxy and any custom client are deliberately kept out of the repo
for now; the devuser channel (`connect.sh`, `q20ssh`, qconn 8000) is unchanged.

## 15. Root quest, session four: the root branch is reachable but RTAS-key gated (2026-10-20, device on WiFi)

Ran the experiment from sections 13 and 14 against the live door. Clean,
decisive result: the root branch is reachable with the password, but the root
challenge is bound to the device's own RTAS key, which the password does not
provide. Root via the door is not achievable with the password alone.

### Setup

Dev mode over WiFi (owner enabled "discoverable", same password). The Q20 came
up at `192.168.1.184` with the door on 4455; USB stayed stuck in mass-storage
mode, so WiFi was the usable channel. The door accepts WiFi connections with
dev mode's WiFi discovery on: no wired-only rejection.

The client is `runtime/qnx-shims/door/Q20Door.java`, built on the vendor
`jqconnDoor.jar` classes so all crypto is stock. Baseline `user` mode ran the
full vendor handshake and **re-provisioned devuser**: port 22 opened and
`q20ssh` logged in as `devuser` (`uid`, `home=/accounts/devuser`). So the
password `drstone` and the whole harness are correct over WiFi.

### The root probe and its result

`root` mode sends HELLO, then a ChallengeRequest with an **empty** public key,
the selector proven in section 14 (the daemon's zeroed receive buffer reads the
empty key as 0 and takes the root branch). The wire:

```
HELLO ->
  feedback <- code=2 (FEEDBACK) payload 0000 0000   (OK)
CHALLENGE_REQUEST (empty key = root selector) ->
  challenge response <- code=4 (ENCRYPTED_CHALLENGE_RESPONSE) len=168
  challenge: version=0x100 sessionKeyType=3 containerKeyVersion=1
             sourceName="QCONN-r144" sigType=1
  local RTAS decrypt => FAIL
```

Two facts, both decisive:

1. **The daemon took the root branch.** The empty-key ChallengeRequest was not
   rejected; the daemon answered with a real 168-byte encrypted challenge. So
   the root selector works exactly as the static analysis predicted, and root
   is not gated by the client being unable to *ask*.
2. **The root challenge is bound to `QCONN-r144`, not to us.** In the devuser
   flow the daemon encrypts the challenge to the client's own public key (which
   `LocalRTASConnection` generated, so the client decrypts it). For root, with
   no client key, the daemon encrypts to its own RTAS key named `QCONN-r144`,
   and `LocalRTASConnection.decrypt` fails. Answering it needs the `QCONN-r144`
   private key, which is RTAS/debug-token grade and is not derived from the
   device password.

### Where this leaves root

The password unlocks devuser; it does not unlock root. The door's root branch
is a real, reachable code path, but its challenge is cryptographically gated by
the `QCONN-r144` RTAS key. The only ways past it:

* **Recover the `QCONN-r144` private key.** Whether it is the OS-shipped
  "fallback RTAS key" the daemon logs (potentially static and extractable) or a
  per-device key in protected storage is unknown and untested; probing for the
  key on the device is credential extraction and is left as an explicit owner
  decision, not pursued here.
* A QNX-side privilege path independent of the door (section 9 list items 2 to
  4), still open.

So A7 compositing, which needs root (section 12), stays blocked, and the
drawing half of A7 remains the delivered result. The devuser channel is fully
working over WiFi now, which is a simpler path than the USB dance for everyday
work: `Q20_IP=192.168.1.184 q20ssh`.

The experiment client and proxy live in `runtime/qnx-shims/door/` (gitignored).

## 16. The QCONN key is a public modulus; the door is closed (2026-10-20)

Session five of the root quest extracted the OS image and settled the one open
question from sections 13 to 15: whether the `QCONN-r144` key the door uses is
a keypair recoverable from the OS (then root via the door) or a public key
whose private half never shipped (then the door is closed).

### What was extracted, and how

The official Classic autoloader (`SQC100-1.Classic.BB10_3_3.10.3.3.498.exe`,
the 10.3.3.3216 release, from archive.org item `blackberry10-autoloaders`,
md5 `c79f8a390232a9f7a5824f9ab4e21f69`) was parsed with the research tools in
`Blackberry-Research/tools/`: the exe is `cap.exe` + a ver2 header + three
`mfcq` containers. The IFS stream (type 0x08, 10.9 MB) was LZO-decompressed
(`dumpifs.py`) and yielded `proc/boot/librtas.so.1` (332,153 bytes) plus the
Certicom libs. Byte comparison against the device: the autoloader's
`libhuapi.so.5` and `libsbgse56.so.0` are identical to the device's
`/proc/boot` copies, so this image is exactly the firmware the device runs,
and this `librtas.so.1` is the device's own.

`librtas.so.1` keeps its key table in plaintext while its code is
kernel-decrypted at load (the `.text` around `GetEncryptionChallengeEx` and
`RTAS_LoadQconnKeyExV2` is ciphertext in the image; the entry point, string
tables and the key table are plaintext). The table is the definitive artifact:

```
entry = name[32] || blob[128] || name[32] || blob[128] || {len=0x80, count=1} || model[32]
QCONN-r143 -> _CLASSICROW_      QCONN-r144 -> _CLASSICATT_   QCONN-r146 -> _CLASSICVZW_
QCONN-r113 -> _CLASSICVZWNC_    QCONN-development -> _WINDERMERESPRINT_   ... 68 entries
```

Every hardware model has one 1024-bit blob, stored twice per entry (identical
copies), selected by `locateKey` after the log line `No device specific QCONN
key found.` (the per-device debug-token key does not exist on this device).
Our device matched `QCONN-r144`, which is exactly the `sourceName` the door
returned on the wire in section 15. The r144 wire challenge parses as
`version=0x100, sessionKeyLength=16 (AES-128), sessionKeyType=3,
containerLength=128, sigType=1, containerKeyVersion=1` with a 128-byte RSA
container: the challenge is RSA-1024-encrypted to the model's key.

### The verdict

The 128-byte table blobs are **public moduli**, not keypairs. Three
independent facts pin this:

1. **API contract.** The daemon passes the loaded key blob straight to
   `GetEncryptionChallengeEx(name, blob, 128, ...)`. In the devuser path that
   same argument is the client's public modulus from the request, plaintext;
   in the daemon's own fallback path it is the static blob in the daemon's
   `.rodata`. Both of those work without any decryption step, so the root path
   passes a plaintext modulus too.
2. **The daemon never needs a private half.** It encrypts the challenge and
   verifies the client's response signature; both are RSA public operations.
   Shipping private halves for every model in every device's flash would be a
   pointless secret spread, and the table region is plaintext (the names and
   model strings beside the blobs are not encrypted), so the blobs are not
   hiding behind the binary's code encryption either.
3. **Structure.** All 68 blobs are odd 1024-bit values with no small factors
   and top bit set; none of them (nor the daemon's `QCONN-R031` fallback blob)
   appears anywhere else in the image, the vendor jars, or the RFS.

So the door's root branch is cryptographically bound to per-model RSA keys
whose private halves lived in RIM's RTAS infrastructure and are not on the
device, not in the OS image, and not in the client tooling. The password
unlocks devuser; the door root needs a RIM-held key. That closes the door
track with a clean negative, confirmed from the shipped image rather than
inferred from behavior.

### What remains for root

* **The pre-rooted autoloader reflash**, the method the research repo already
  validated on a Classic (`Blackberry-Research/`, finding 1 and
  `notes/session7o-classic-real-root.md`): bake `btool` + the
  `ota_info_pps.sh` autoroot symlink + `pathtrust !/base/bin/__root` into the
  OS image, reflash, get real uid-0 every boot. We now hold the exact
  autoloader it needs. Cost: full wipe, Windows `cap.exe` (or `bb10mt`, which
  has the red-blink caveat on the Passport but was not the lane used for the
  Classic root) and brick risk bounded by the proven cap.exe recovery.
* The QNX-side privilege paths independent of the door (section 9 items 2 to
  4), still open and now the only non-reflash candidates.

The artifacts (autoloader, IFS extraction, `librtas.so.1`, table dump) live in
the gitignored research dir next to the door client
(`runtime/qnx-shims/door/librtas.so.1.autoloader`).

## 17. Reflash quest: image built and flashed, boot-slot commit outstanding (2026-10-20)

The owner chose the reflash route (the method validated in `Blackberry-Research/`,
finding 1 and `notes/session7o-classic-real-root.md`). A pre-rooted image was
built from the stock Classic autoloader and flashed over USB with the macOS
bb10mt lane. Status: the user-partition payload landed and works; the OS-copy
(rcfs) modification flashes but the device never boots it. The remaining path
is the proven Windows cap.exe lane.

### What was built

* **Image changes (both baked into the flash):**
  * UFS (user partition): the getroot device-configuration package under
    `/var/android/getroot` (mounts `fs1.rcfs` at `/q` with setuid impersonation
    helpers `u_*`/`g_*`, one per uid/gid, e.g. `u_upd`, `u_root`),
    `/root/.ssh/authorized_keys` carrying the owner's q20 public key,
    `/var/etc/ssh/sshd_config` (root login), and the persisted PPS triggers.
  * RCFS (OS): `/scripts/ota_info_pps.sh` replaced with an autoroot payload
    that copies `__root` (compiled from the asroot source, ARM QNX) to
    `/base/bin`, pathtrust-whitelists it, and restarts sshd with the root
    config.
* **Toolchain:** bb10mt v0.6.0.0 built from source on Apple Silicon (Lazarus
  4.8 + FPC 3.2.4 local prefix, mormot2 + cli_fp + synapse + LGenerics +
  pas-libusb + pl_ExCompress LZMA units). A local libusb-1.0 Pascal binding and
  an OOP shim were written because the upstream pas-libusb is the 0.1 API.
  Patched sources are saved under
  `runtime/qnx-shims/door/reflash/bb10mt-patches/`.
* **Artifacts (large, in `~/q20-flash/`):** `stock-autoloader.exe` (the
  official SQC100-1 autoloader, md5 `c79f8a390232a9f7a5824f9ab4e21f69`),
  `OS.signed.unsigned` (modified streams + the real 560-byte install seal
  appended), `radio.signed`, `cap_patched.exe` (3-byte signature-bypass patch,
  recipe in `Blackberry-Research/notes/session9b-ifs-verify-cap-diff.md`).
  `rooted.exe` (the cap.exe lane image) is rebuildable from these with
  `bb10mt autoloader create`. Small artifacts (flash scripts, the RAM loader,
  the seal, the payloads) live in `runtime/qnx-shims/door/reflash/`.

### Facts learned on the flash lane (worth not rediscovering)

* The Classic's boot ROM enumerates as `0fca:0001`; the password challenge is
  the device's own lock password via HashPassV2 (the door password works).
  SetMode answers `0x08` on a fresh session and `0x09` for "already in
  bootloader mode"; accepting both fixes reconnect after a killed session.
* A half-open session wedges the boot ROM (challenge reads time out) until a
  Reboot command (Channel0 cmd 3) + reconnect; the flow needs an explicit
  retry.
* The Classic's RAM loader is devID `9400270A` (load address `0x80200000`,
  gzip-compressed inside cap.exe's `.data` loader table at 213 entries);
  cap.exe also carries the per-model loader table. The 8D002C0A loader is the
  Passport's, not the Classic's.
* The stock OS container ends with the real 560-byte `QNXH-OS-1` install seal
  (`1f2dc8d7` footer); the bb10mt pack omits it and sends a fake one.
* UFS modifications survive and take effect (getroot applied on the first
  boot after each flash). RCFS modifications flash without error but the
  device always boots `os1` with the stock rcfs; the switchzone PPS job
  (`/pps/system/installer/upd/current/sz`, `session::1` on this device)
  returns success but the slot never flips. Conclusion: the macOS lane is
  missing the flash-time boot-slot commit that Windows cap.exe performs
  ("cap.exe does more flash-time state than just F9",
  `Blackberry-Research/README.md` finding 12 and open lead 7).

### Where this leaves root

* **Proven remaining path:** flash `rooted.exe` via patched cap.exe on
  Windows (the exact lane the research repo used for the Classic; red-blink
  recovery by re-flashing stock is proven). Needs a Windows machine or a VM
  with USB passthrough.
* **Open macOS ideas:** capture the cap.exe USB session to learn the missing
  commit commands and add them to bb10mt; or, after a fresh flash, use the
  device's own `g_Disk_Drivers` helper from `/q` to raw-write the modified
  rcfs into `os1t179` and reboot. In progress: `Blackberry-Research/tools/
  bblink.py` now has hardened bring-up (reboot-and-retry wedge clearing,
  mirroring bb10mt's recovery) plus `get_mct`/`set_active_mct` commands, with
  the idea of flipping the active OS slot through the loader's MCT once the
  `ACTIVE_OS_OFFSET` is pinned from a live read; the bring-up handshake still
  failed in its last session (bootrom opened but the loader handshake did not
  complete).

A7 compositing remains blocked on this; the drawing half and the devuser
toolchain are unaffected.

### 17a. cap.exe RE: the missing commit is D7 SetActiveMCT (2026-10-21, macOS static RE)

Static RE of `~/q20-flash/cap_patched.exe` (PE32 x86, rizin, no Windows) pinned
the flash-time state the macOS lane omits. The finalize path is an MCT
**read-modify-write**:

* `GetMCT` routine at `0x4483f4` ("Retrieving MCT") sends loader command **`D9`**
  and expects response **`0xC9`** (matches `bblink.py get_mct`).
* `SetActiveMCT` routine at `0x4499c0` ("SetActiveMCT is complete") sends loader
  command **`D7`** with the MCT buffer (size-gated to `<= 0x1000`), retrying
  while the device is busy (devctl `0x6c`, 300 ms backoff).
* Both go through the channel2 send-wrapper `0x445ad0` ("Re-Sending (0x%02X,%d)").
* The orchestrator `0x40da30` logs **"Backing up and updating active MCT via
  device-side command"** and calls `SetActiveMCT(buffer, size)`; it is gated on
  the device-family field `[this+4] == 6` (this device). cap.exe also tracks
  `activeMct:` / active-vs-inactive bootrom metrics, i.e. the dual OS-slot state.

The patched bb10mt lane (`ramloader.pas` tail) sends only
`SendBlock -> SendSignature(F9) -> Complete(40C0) -> Reboot`; it never issues
`D7`, so the active-OS slot is never committed and the device keeps booting the
stock `os1`. This is exactly "cap.exe does more flash-time state than just F9".

Ported into `Blackberry-Research/tools/bblink.py` (already speaks channel2 + `D9`
get_mct): new `set_active_mct` (`D7`, size gate + busy retry), `commit_active_mct`
(read-modify-write), and CLI verbs `getmct` / `setactivemct`. The one value still
to pin is the active-OS byte inside the MCT: `BBSession.ACTIVE_OS_OFFSET` is left
`None` until a live `getmct` diff (stock vs desired) identifies it; until then
`commit_active_mct()` only writes the MCT back verbatim (proves the `D7` path
without flipping the slot). `python3 bblink.py selftest` covers the `D7` size gate
offline.

Next on hardware: `bblink.py getmct -f mct.bin` in a loader session, parse with
`boot0_flash.py:parse_mct`, pin `ACTIVE_OS_OFFSET`, then flash + `commit_active_mct`
and confirm the device boots the autoroot rcfs. Red-blink recovery by re-flashing
`stock-autoloader.exe` is proven.

## 18. Flash lane completed, MCT flip attempted, installer route next (2026-10-20)

Session six of the root quest ran the macOS flash lane end to end and tried
the boot-slot flip; the lane is now fully mapped, and the next route is a
runtime installer trick that sidesteps the boot0 wall.

### The bblink lane is fixed and working

`Blackberry-Research/tools/bblink.py` (kept out of git with the rest of the
research tree) now performs the full bring-up that bb10mt did:

* The bring-up bug was the **CRC flavour**: the wire CRC is the zlib-style
  CRC32 (init xor + final xor, matching the FPC crc unit), not a raw table
  CRC. With the raw CRC every channel1 frame was NACKed (response 0x15) and
  the loader upload silently did nothing.
* `connect()` now has a 3-attempt outer loop with a wedge-clearing reboot
  between attempts (mirrors bb10mt's recovery), plus `get_mct` / `set_active_mct`
  (D9/D7) commands.
* Verified live: boot ROM 0fca:0001 -> password challenge -> loader 9400270A
  upload (0x80200000) -> RAM loader 0x8001 -> flash-regions info, PIN/BSN,
  and the 976-byte MCT read.

### The MCT format (from the live read)

```
magic 0x92BE564A | version 1.28 (u16 minor,major) | TLV entries [type:1][size:1][body]
  type 0x39 = partition: [unk:1][flags:1][name:12][start:4][end:4]
    offset = start<<16, size = (end-start+1)<<16
  terminator type 9, then a zlib CRC32 over bytes 0..967 at offset 972.
```

Two OS copies: set A at start 0x0820 (sub-flags os_mbr=0x20, os_sig=0x40,
system=0x40, os_fsys=0x40) and set B at 0x2820 (all 0x00). The device boots
`/dev/emmc/os1t179` (set A). A flipped MCT (set A flags zeroed, set B raised,
CRC recomputed) was accepted by D7 and the loader rebooted, but the device
still boots set A: the boot-time slot selection lives in the write-protected
boot0 region (the research repo's central wall), so the D7 path cannot commit
the flip. This closes the MCT idea with a clean negative.

### The next route: installer links asset (runtime, no boot0 writes)

The device-configuration package machinery applies a `links` asset at install
time AS ROOT. The shipped getroot package only mounts (`mount:src:dst:type`),
but the same machinery plausibly creates symlinks, which would let us replace
`/base/scripts/ota_info_pps.sh` at runtime with a link to a payload on the
user partition (then the switchzone trigger runs it as root, completing the
autoroot chain). The first step is reading the deckard installer python on the
device to learn the links directive format, then re-installing a modified
getroot package through the installer queue (reachable via the `/q` `u_upd`
impersonation helper, which returns on the first boot after each flash).
