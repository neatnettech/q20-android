#!/bin/sh
# Build q20facade.jar on the host: javac + d8, no resources. Output in build/.
# Same tools as apps/q20prober/build.sh (toolchains/android-tools, gitignored).
# Hidden framework APIs are reached by reflection, so the public android-23.jar
# is enough to compile against.
set -e
cd "$(dirname "$0")"
T=../../toolchains/android-tools
JAVA=/opt/homebrew/opt/openjdk/bin/java
JAVAC=/opt/homebrew/opt/openjdk/bin/javac

rm -rf build
mkdir -p build/classes build/dexout

"$JAVAC" -source 1.8 -target 1.8 \
  -bootclasspath "$T/android-23.jar" -classpath "$T/android-23.jar" \
  -d build/classes $(find src -name '*.java')

"$JAVA" -cp "$T/r8.jar" com.android.tools.r8.D8 --release --min-api 18 \
  --lib "$T/android-23.jar" --output build/dexout \
  $(find build/classes -name '*.class')

python3 - <<'EOF'
import zipfile
with zipfile.ZipFile('build/q20facade.jar', 'w', zipfile.ZIP_DEFLATED) as z:
    z.write('build/dexout/classes.dex', 'classes.dex')
print('wrote build/q20facade.jar')
EOF
