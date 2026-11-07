#!/bin/bash
# S2 smoke: compile one stock graphics JNI file against Skia + the stubs.
# Run in the aosp6 container after sourcing the toolchain env. Not a build
# artifact; scratch for iterating the include set.
set -u
P=/workspace/project
SK=$P/external/skia
SKINC="-I$SK/include/config -I$SK/include/core -I$SK/include/pathops \
 -I$SK/include/effects -I$SK/include/images -I$SK/include/ports \
 -I$SK/include/utils -I$SK/include/gpu -I$SK/include/pipe -I$SK/include/codec \
 -I$SK/src/core -I$SK/src/image -I$SK/src/opts -I$SK/src/utils -I$SK/src/sfnt \
 -I$SK/src/ports -I$SK/src/lazy -I$SK/src/effects -I$SK/src/images"
QNX=$P/toolchains/playbook-gcc9/qnx650/include
# skia-compat FIRST: its Caches.h/ResourceCache.h/TextureCache.h stubs must
# shadow the real hwui ones (which drag in the GPU stack); Canvas.h is not
# stubbed, so it still falls through to the real (clean) hwui header.
# compat first of all: its stdatomic.h shadows the toolchain's C11 one, which
# breaks in C++ (_Atomic not a keyword). Same as the main build's CXXFLAGS.
JNI="-I$P/runtime/art-qnx/compat \
 -I$P/runtime/art-qnx/skia-compat \
 -I$P/frameworks/base/core/jni -I$P/frameworks/base/core/jni/android/graphics \
 -I$P/frameworks/base/include -I$P/frameworks/base/libs/hwui \
 -I$P/frameworks/native/include \
 -I$P/system/core/include -I$P/libnativehelper/include/nativehelper \
 -I$P/libnativehelper/include -I$P/bionic/libc/kernel/uapi \
 -I$P/bionic/libc/kernel/uapi/asm-arm -I$QNX -I$QNX/freetype2"
DEFS="-DSK_BUILD_FOR_ANDROID= -DSK_ARM_HAS_NEON -DSKIA_IMPLEMENTATION=1 -DNDEBUG"
FLAGS="-O2 -std=gnu++11 -fno-rtti -fno-exceptions -fno-strict-aliasing -Wno-narrowing -fpermissive \
 -include $P/runtime/art-qnx/compat/art_qnx_compat.h"
f=${1:-android/graphics/Matrix.cpp}
out=$P/runtime/art-qnx/build/skia-jni
mkdir -p $out
err=$out/$(basename $f .cpp).err
arm-blackberry-qnx8eabi-g++ $FLAGS $DEFS $SKINC $JNI \
  -c $P/frameworks/base/core/jni/$f -o $out/$(basename $f .cpp).o 2> $err
rc=$?
# Skia drags in a flood of -Wignored-attributes; show only real diagnostics.
grep -E 'error:|fatal error:' $err | head -20
echo "exit $rc"
