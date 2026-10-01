#!/bin/sh
# Build q20prober.apk on the host: aapt2 + javac + d8. Output in build/.
# Requires the android-tools under toolchains/android-tools (gitignored):
#   aapt2-bin/aapt2, android-23.jar, r8.jar
set -e
cd "$(dirname "$0")"
T=../../toolchains/android-tools
JAVA=/opt/homebrew/opt/openjdk/bin/java
JAVAC=/opt/homebrew/opt/openjdk/bin/javac

rm -rf build
mkdir -p build/gen

"$T/aapt2-bin/aapt2" compile --dir res -o build/res.zip
"$T/aapt2-bin/aapt2" link -o build/base.apk -I "$T/android-23.jar" \
  --manifest AndroidManifest.xml -R build/res.zip --java build/gen \
  --auto-add-overlay \
  --min-sdk-version 18 --target-sdk-version 18 \
  --version-code 1 --version-name 1.0

"$JAVAC" -source 1.8 -target 1.8 \
  -bootclasspath "$T/android-23.jar" -classpath "$T/android-23.jar" \
  -d build/classes \
  $(find src build/gen -name '*.java')

mkdir -p build/dexout
"$JAVA" -cp "$T/r8.jar" com.android.tools.r8.D8 --release --min-api 18 \
  --lib "$T/android-23.jar" --output build/dexout \
  $(find build/classes -name '*.class')

python3 - <<'EOF'
import zipfile
src = zipfile.ZipFile('build/base.apk', 'r')
dst = zipfile.ZipFile('build/q20prober.apk', 'w', zipfile.ZIP_DEFLATED)
for item in src.namelist():
    dst.writestr(item, src.read(item))
with open('build/dexout/classes.dex', 'rb') as d:
    dst.writestr('classes.dex', d.read())
dst.close()
print('wrote build/q20prober.apk')
EOF


# Sign v1 (JAR) for Android 4.3 / API 18. apksigner from the Android SDK
# build-tools; a modern JDK jarsigner disables SHA1 and emits a digest that
# 4.3 rejects as "Incorrect signature", so apksigner is required here.
#   APKSIGNER=path/to/build-tools/35.0.0/apksigner sh build.sh
APKSIGNER="${APKSIGNER:-$HOME/Library/Android/sdk/build-tools/35.0.0/apksigner}"
KS="${Q20_KEYSTORE:-build/q20-debug.jks}"
if [ ! -f "$KS" ]; then
  "/opt/homebrew/opt/openjdk/bin/keytool" -genkeypair -keystore "$KS"     -storepass android -keypass android -alias q20 -keyalg RSA -keysize 2048     -validity 10000 -dname "CN=Q20 Debug,O=fun,C=US" >/dev/null 2>&1
fi
if [ -x "$APKSIGNER" ]; then
  "$APKSIGNER" sign --ks "$KS" --ks-pass pass:android --key-pass pass:android \
    --min-sdk-version 18 --v1-signing-enabled true \
    --v2-signing-enabled false --v3-signing-enabled false \
    build/q20prober.apk
  echo "signed build/q20prober.apk (v1, API 18)"
else
  echo "WARNING: apksigner not found at $APKSIGNER; apk is UNSIGNED and will not install on 4.3"
fi
