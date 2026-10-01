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
