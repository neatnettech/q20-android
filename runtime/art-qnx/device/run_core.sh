#!/bin/sh
# On-device bring-up runner for the QNX ART port. Run from the staging dir
# (see "make -f art-qnx.mk stage", then copy the whole dir to the Q20).
#
# Targets:
#   core    4 dex core boot image (fast card table / GC check, minutes)
#   boot13  full 13 dex boot image (the real thing, long)
#   hello   run Hello under the last built image, AOT then interpreter
#   all     core then hello
#   prober  Prober APK headless self test (main), AOT then interpreter
#   facade  [props|res|looper|gfx|activity|all] our launcher running the Prober
#           Activity headless (A6), each mode one facade layer; default activity
#   tap     [id ...] [id=text ...] headless real touch taps on the app's views,
#           then checks; e.g. tap bump_button "counter_text=count: 1"
#   snap    copy the last live frame to out/frame.rgba (raw 720x720 RGBA)
#   live    the app ($APP_APK) live on the panel: needs the resident root
#           compositor (FACADE_WATCH=1) watching $Q20_DRAW_RAW; log in out/live.log
#
# Hello prints "Hello from ART 6 on QNX! gc ok" only if a full GC ran with a
# live heap object, so it doubles as the GC regression check.
#
# -Ximage takes the location without the isa dir: ART inserts "arm" itself
# (GetSystemImageFilename), which is why the images are written to out/arm.

Q=$(cd "$(dirname "$0")" && pwd)
export ANDROID_ROOT=$Q/system ANDROID_DATA=$Q/data
export LD_LIBRARY_PATH=$Q/lib:$LD_LIBRARY_PATH
mkdir -p $Q/system $Q/data/tmp $Q/data/dalvik-cache $Q/out/arm

CORE_DEX="core-libart conscrypt okhttp bouncycastle"
BOOT13_DEX="core-libart conscrypt okhttp bouncycastle ext framework framework2 \
telephony-common voip-common ims-common apache-xml org.apache.http.legacy.boot core-junit"
BCP13=""
for d in $BOOT13_DEX; do BCP13="$BCP13:$Q/boot/$d.dex"; done
BCP13=${BCP13#:}

# The app the facade and live targets run: the Prober unless these name another,
# e.g. APP_APK=$Q/calculator.apk APP_ACT=com.android.calculator2.Calculator
APP_APK=${APP_APK:-$Q/q20prober.apk}
APP_ACT=${APP_ACT:-dev.q20.prober.Q20Prober}

# dex2oat flags proven on device: Quick backend (the optimizing backend is not
# built), krait variant, -j1 (parallel compile is unverified since the GC fix).
#
# --image-classes is mandatory for an image build. Without it dex2oat builds an
# EMPTY image class set (dex2oat.cc:1223), CompilerDriver::IsImageClass then
# answers false for every class, PruneNonImageClasses strips all of them, and
# ImageWriter::FixupPointerArray later dies on an ArtField with no relocation
# entry (while formatting its own LOG(FATAL), so the visible crash is a SIGSEGV
# in PrettyField). AOSP always passes this: art/build/Android.oat.mk uses
# --image-classes=$PRELOADED_CLASSES for both core and boot images.
# --image-classes and --base are image-only; the standalone hello compile
# rejects them (dex2oat.cc:152).
IMAGE_FLAGS="--instruction-set=arm --instruction-set-variant=krait \
  --compiler-backend=Quick -j1 --base=0x6f000000 --android-root=$Q/system \
  --image-classes=$Q/preloaded-classes"
COMPILE_FLAGS="--instruction-set=arm --instruction-set-variant=krait \
  --compiler-backend=Quick -j1 --android-root=$Q/system"
HEAP="--runtime-arg -Xms64m --runtime-arg -Xmx256m"
# Extra flags for one-off experiments, e.g.
#   DEX2OAT_EXTRA="--runtime-arg -Xgc:nonconcurrent" sh run_core.sh core
EXTRA=${DEX2OAT_EXTRA:-}

build_image() {
  name=$1; shift
  args=""
  bcp=""
  for d in $*; do
    args="$args --dex-file=$Q/boot/$d.dex"
    bcp="$bcp:$Q/boot/$d.dex"
  done
  echo "$bcp" | sed 's/^://' > $Q/out/$name.bcp
  rm -f $Q/out/arm/$name.art $Q/out/arm/$name.oat
  echo "=== $name image: $(date)"
  $Q/bin/dex2oat $HEAP $args \
    --oat-file=$Q/out/arm/$name.oat --image=$Q/out/arm/$name.art \
    $IMAGE_FLAGS $EXTRA > $Q/out/$name-dex2oat.log 2>&1
  echo "dex2oat exit=$? at $(date)"
  grep -E "art: fatal|FATAL|Check failed|Out of memory" $Q/out/$name-dex2oat.log | sed 20q
  ls -la $Q/out/arm
  echo "$name" > $Q/out/last-image
}

run_hello() {
  name=$(cat $Q/out/last-image 2>/dev/null || echo core)
  bcp=$(cat $Q/out/$name.bcp)

  # ART finds a precompiled oat under $ANDROID_DATA/dalvik-cache/<isa> with the
  # dex location mangled: leading slash dropped, every / turned into @
  # (GetDalvikCacheFilename). Compile Hello there so the aot run executes our
  # own Quick output instead of the interpreter.
  cache=$Q/data/dalvik-cache/arm
  mkdir -p $cache
  oat=$cache/$(echo "$Q/hello.dex" | sed 's,^/,,; s,/,@,g')
  rm -f "$oat"
  echo "=== hello.oat: $oat"
  $Q/bin/dex2oat $HEAP --dex-file=$Q/hello.dex --oat-file="$oat" \
    --boot-image=$Q/out/$name.art --runtime-arg -Xnorelocate \
    $COMPILE_FLAGS $EXTRA > $Q/out/hello-dex2oat.log 2>&1
  echo "dex2oat exit=$? at $(date)"
  tail -5 $Q/out/hello-dex2oat.log
  ls -la "$oat" 2>/dev/null

  for mode in aot int; do
    case $mode in
      aot) xflags="" ;;
      int) xflags="-Xint" ;;
    esac
    echo "=== hello ($mode) under $name image"
    $Q/bin/dalvikvm -Xbootclasspath:$bcp -Ximage:$Q/out/$name.art -Xnorelocate \
      $xflags -cp $Q/hello.dex Hello > $Q/out/hello-$mode.log 2>&1
    echo "dalvikvm exit=$?"
    tail -25 $Q/out/hello-$mode.log
  done
  echo "=== expected on success: Hello from ART 6 on QNX! gc ok (both modes)"
}

# Compile an APK or jar against boot.art (from boot13) into the dalvik cache,
# where dalvikvm finds it: location mangled as for hello, plus @classes.dex for
# the entry inside the zip.
aot() {
  cache=$Q/data/dalvik-cache/arm
  mkdir -p $cache
  oat=$cache/$(echo "$1" | sed 's,^/,,; s,/,@,g')@classes.dex
  rm -f "$oat"
  $Q/bin/dex2oat $HEAP --dex-file=$1 --oat-file="$oat" \
    --boot-image=$Q/out/boot.art --runtime-arg -Xnorelocate \
    $COMPILE_FLAGS > $Q/out/$(basename $1)-dex2oat.log 2>&1
  echo "dex2oat $(basename $1) exit=$? at $(date)"
}

run_prober() {
  # The Q20 Prober APK (A ladder): headless main() self test, AOT and
  # interpreted.
  echo "$BCP13" > $Q/out/prober.bcp
  aot $Q/q20prober.apk
  for mode in aot int; do
    case $mode in
      aot) xflags="" ;;
      int) xflags="-Xint" ;;
    esac
    echo "=== prober ($mode) under boot image"
    $Q/bin/dalvikvm -Xbootclasspath:$BCP13 -Ximage:$Q/out/boot.art -Xnorelocate \
      $xflags -cp $Q/q20prober.apk dev.q20.prober.Q20Prober > $Q/out/prober-$mode.log 2>&1
    echo "dalvikvm exit=$?"
    grep "prober:" $Q/out/prober-$mode.log
  done
}

run_facade() {
  # Our launcher (q20facade.jar) running an unmodified APK ($APP_APK), one mode.
  for mode in aot int; do
    case $mode in
      aot) xflags="" ;;
      int) xflags="-Xint" ;;
    esac
    log=$Q/out/facade-$1-$mode.log
    echo "=== facade $1 ($mode)"
    $Q/bin/dalvikvm -Xbootclasspath:$BCP13 -Ximage:$Q/out/boot.art -Xnorelocate $xflags \
      -cp $Q/q20facade.jar:$APP_APK dev.q20.facade.Launcher $1 \
      $APP_APK $APP_ACT > $log 2>&1
    echo "dalvikvm exit=$?"
    grep -E "facade|Q20Prober|UnsatisfiedLinkError|Exception|Error|FATAL|art: fatal" $log | sed 80q
  done
}

run_live() {
  # Never returns: the launcher polls the compositor's input file and redraws
  # into the frame file the compositor posts. Runs as long as the shell that
  # started it (no nohup here), so hold that ssh session open.
  export Q20_DRAW_RAW=${Q20_DRAW_RAW:-/tmp/frame.rgba}
  echo "=== live: frame $Q20_DRAW_RAW, log $Q/out/live.log"
  exec $Q/bin/dalvikvm -Xbootclasspath:$BCP13 -Ximage:$Q/out/boot.art -Xnorelocate \
    -cp $Q/q20facade.jar:$APP_APK dev.q20.facade.Launcher live \
    $APP_APK $APP_ACT > $Q/out/live.log 2>&1
}

run_tap() {
  # The app's Activity, real MotionEvent taps on the named views in order,
  # then each id=text checked (Launcher tap mode).
  log=$Q/out/tap.log
  $Q/bin/dalvikvm -Xbootclasspath:$BCP13 -Ximage:$Q/out/boot.art -Xnorelocate \
    -cp $Q/q20facade.jar:$APP_APK dev.q20.facade.Launcher tap $APP_APK $APP_ACT "$@" > $log 2>&1
  echo "dalvikvm exit=$?"
  grep -v "^art " $log | grep -E "facade (check|: tap)|UnsatisfiedLinkError|Exception|art: fatal" | sed 60q
}

case ${1:-all} in
  core)   build_image core $CORE_DEX ;;
  boot13) build_image boot $BOOT13_DEX ;;
  hello)  run_hello ;;
  prober) run_prober ;;
  facade) aot $APP_APK && aot $Q/q20facade.jar
          w=${2:-activity}
          [ "$w" = all ] && w="props res looper gfx activity"
          for x in $w; do run_facade $x; done ;;
  live)   aot $APP_APK && aot $Q/q20facade.jar && run_live ;;
  snap)   cp ${Q20_DRAW_RAW:-/tmp/frame.rgba} $Q/out/frame.rgba && ls -l $Q/out/frame.rgba ;;  # the panel's last frame, 720x720 RGBA
  tap)    shift; aot $APP_APK && aot $Q/q20facade.jar && run_tap "$@" ;;
  all)    build_image core $CORE_DEX && run_hello ;;
  *)      echo "usage: sh run_core.sh [core|boot13|hello|prober|facade [mode]|tap [ids]|live|snap|all]"; exit 2 ;;
esac
