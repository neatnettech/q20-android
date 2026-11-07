#!/bin/sh
# Build notepad.apk on the host from the unmodified AOSP 6.0.1 NotePad sample
# (development/samples/NotePad at android-6.0.1_r81, gitignored):
# aapt2 + javac + d8, min-sdk 11, no target. Output in build/.
#   packages/samples/NotePad   the gitiles tarball:
#     curl -sL -o notepad.tar.gz \
#       "https://android.googlesource.com/platform/development/+archive/android-6.0.1_r81/samples/NotePad.tar.gz"
# Unsigned: our launcher parses the APK with flags 0, no certificates.
set -e
cd "$(dirname "$0")"
T=../../toolchains/android-tools
APP=../../packages/samples/NotePad
JAVA=/opt/homebrew/opt/openjdk@17/bin/java
JAVAC=/opt/homebrew/opt/openjdk@17/bin/javac

rm -rf build
mkdir -p build/gen build/classes build/dexout

"$T/aapt2-bin/aapt2" compile --dir $APP/res -o build/res.zip
"$T/aapt2-bin/aapt2" link -o build/base.apk -I "$T/android-23.jar" \
  --manifest $APP/AndroidManifest.xml -R build/res.zip --java build/gen \
  --auto-add-overlay \
  --min-sdk-version 11 --target-sdk-version 11 \
  --version-code 1 --version-name 1.0

"$JAVAC" -source 1.8 -target 1.8 -nowarn \
  -bootclasspath "$T/android-23.jar" \
  -classpath "$T/android-23.jar" \
  -d build/classes \
  $(find $APP/src build/gen -name '*.java')

"$JAVA" -cp "$T/r8.jar" com.android.tools.r8.D8 --release --min-api 11 \
  --lib "$T/android-23.jar" \
  --output build/dexout \
  $(find build/classes -name '*.class')

python3 - <<'EOF'
import zipfile
src = zipfile.ZipFile('build/base.apk', 'r')
dst = zipfile.ZipFile('build/notepad.apk', 'w', zipfile.ZIP_DEFLATED)
for item in src.namelist():
    dst.writestr(item, src.read(item))
with open('build/dexout/classes.dex', 'rb') as d:
    dst.writestr('classes.dex', d.read())
dst.close()
print('wrote build/notepad.apk')
EOF
