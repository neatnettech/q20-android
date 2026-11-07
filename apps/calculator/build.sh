#!/bin/sh
# Build calculator.apk on the host from the unmodified AOSP 6.0.1 Calculator
# (packages/apps/Calculator, gitignored): aapt2 + javac + d8. Output in build/.
# Same tools as apps/q20prober/build.sh, plus:
#   packages/apps/Calculator   git clone -b android-6.0.1_r81
#     https://android.googlesource.com/platform/packages/apps/Calculator
#   toolchains/android-tools/support/   from dl.google.com/dl/android/maven2:
#     support-v4-23.1.1.aar (classes.jar + libs/ unzipped into v4/) and
#     support-annotations-23.1.1.jar (compile time only)
# Unsigned: our launcher parses the APK with flags 0, no certificates.
set -e
cd "$(dirname "$0")"
T=../../toolchains/android-tools
S=$T/support
APP=../../packages/apps/Calculator
JAVA=/opt/homebrew/opt/openjdk@17/bin/java
JAVAC=/opt/homebrew/opt/openjdk@17/bin/javac
LIBS="$APP/arity-2.1.2.jar $S/v4/classes.jar $S/v4/libs/internal_impl-23.1.1.jar"

rm -rf build
mkdir -p build/gen build/classes build/dexout

"$T/aapt2-bin/aapt2" compile --dir $APP/res -o build/res.zip
"$T/aapt2-bin/aapt2" link -o build/base.apk -I "$T/android-23.jar" \
  --manifest $APP/AndroidManifest.xml -R build/res.zip --java build/gen \
  --auto-add-overlay \
  --min-sdk-version 21 --target-sdk-version 23 \
  --version-code 1 --version-name 6.0.1

"$JAVAC" -source 1.8 -target 1.8 -nowarn \
  -bootclasspath "$T/android-23.jar" \
  -classpath "$T/android-23.jar:$(echo $LIBS | tr ' ' ':'):$S/support-annotations-23.1.1.jar" \
  -d build/classes \
  $(find $APP/src build/gen -name '*.java')

"$JAVA" -cp "$T/r8.jar" com.android.tools.r8.D8 --release --min-api 21 \
  --lib "$T/android-23.jar" --classpath $S/support-annotations-23.1.1.jar \
  --output build/dexout \
  $(find build/classes -name '*.class') $LIBS

python3 - <<'EOF'
import zipfile
src = zipfile.ZipFile('build/base.apk', 'r')
dst = zipfile.ZipFile('build/calculator.apk', 'w', zipfile.ZIP_DEFLATED)
for item in src.namelist():
    dst.writestr(item, src.read(item))
with open('build/dexout/classes.dex', 'rb') as d:
    dst.writestr('classes.dex', d.read())
dst.close()
print('wrote build/calculator.apk')
EOF
