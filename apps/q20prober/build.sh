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
  --min-sdk-version 23 --target-sdk-version 23 \
  --version-code 1 --version-name 1.0

"$JAVAC" -source 1.8 -target 1.8 \
  -bootclasspath "$T/android-23.jar" -classpath "$T/android-23.jar" \
  -d build/classes \
  $(find src build/gen -name '*.java')

mkdir -p build/dexout
"$JAVA" -cp "$T/r8.jar" com.android.tools.r8.D8 --release --min-api 23 \
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
