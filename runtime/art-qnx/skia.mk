# NOD-30: AOSP Skia (external/skia at android-6.0.1_r81), CPU backend only,
# behind the Canvas JNI in libjavacore. Included by art-qnx.mk above the
# libjavacore rule. The objects link straight into libjavacore.so: as an
# archive the PNG decoder, reached only through its static registrar, would
# be dropped.
#
# Source (gitignored, like the other AOSP trees), then the patches:
#   git clone --depth 1 -b android-6.0.1_r81 \
#     https://android.googlesource.com/platform/external/skia external/skia
#   make -f art-qnx.mk patches
# 0110 SkUserConfig for QNX (GPU and PDF off, little endian, BGRA native
# pixels), 0111 the PNG decoder against the sysroot's libpng 1.4 (no region
# decoder).
SKIA ?= $(abspath ../../external/skia)

# Skia's own source list (Android.mk, LOCAL_SRC_FILES up to the libraries),
# minus what a CPU only QNX build cannot or need not build: GPU, PDF, the
# codec and C APIs, pipe, the font proxies, decoders whose libraries the
# sysroot lacks (jpeg, gif, webp), the texture compressors (etc1, ktx) and
# Android's font manager (fonts.xml through expat). Fonts come from files
# (SkFontHost_linux), the way graphics_facade.cc already loads Roboto.
SKIA_SRCS := $(shell sed -n '/^LOCAL_SRC_FILES := /,/^LOCAL_SHARED_LIBRARIES/p' $(SKIA)/Android.mk \
  | grep -oE 'src/[^ ]+\.cpp' \
  | grep -vE '^src/(gpu|pdf|doc|codec|c|pipe|fonts)/|_Gpu\.cpp' \
  | grep -vE 'SkFlate|SkTextureCompressor|SkDeferredCanvas|SkForceLinking|SkMovie|SkImageDecoder_lib(gif|webp|jpeg)|SkJpegUtility|SkFontMgr_android|SkFontConfigParser_android')
SKIA_SRCS += src/ports/SkFontHost_linux.cpp \
  src/core/SkUtilsArm.cpp \
  src/opts/SkBitmapProcState_opts_arm.cpp src/opts/SkBlitMask_opts_arm.cpp \
  src/opts/SkBlitRow_opts_arm.cpp src/opts/SkBlurImage_opts_arm.cpp \
  src/opts/SkMorphology_opts_arm.cpp src/opts/SkUtils_opts_arm.cpp \
  src/opts/SkXfermode_opts_arm.cpp \
  src/opts/SkBitmapProcState_arm_neon.cpp src/opts/SkBitmapProcState_matrixProcs_neon.cpp \
  src/opts/SkBlitMask_opts_arm_neon.cpp src/opts/SkBlitRow_opts_arm_neon.cpp \
  src/opts/SkBlurImage_opts_neon.cpp src/opts/SkMorphology_opts_neon.cpp \
  src/opts/SkUtils_opts_arm_neon.cpp src/opts/SkXfermode_opts_arm_neon.cpp
SKIA_OBJS := $(patsubst %.cpp,build/skia/%.o,$(SKIA_SRCS))

SKIA_INC := $(addprefix -I$(SKIA)/,include/config include/core include/pathops \
  include/effects include/images include/ports include/utils include/gpu include/pipe \
  include/codec src/core src/image src/opts src/utils src/sfnt src/ports src/lazy \
  src/effects src/images)

# SkPreConfig.h picks the platform before SkUserConfig.h runs and, seeing
# none of its macros on QNX, falls through to SK_BUILD_FOR_MAC: name Android
# up front (empty, exactly as SkUserConfig.h defines it). Everything that
# includes Skia headers (the graphics JNI too) needs it. The toolchain
# defaults to armv7 thumb with softfp NEON, so SK_ARM_HAS_NEON needs no
# runtime probe.
SKIA_DEFS := -DSK_BUILD_FOR_ANDROID= -DSK_ARM_HAS_NEON $(SKIA_INC)
SKIA_CFLAGS := -O2 -g -std=gnu++11 -fno-rtti -fno-exceptions -fno-strict-aliasing \
  -Wno-narrowing -Wno-unused-parameter -DNDEBUG -DSKIA_IMPLEMENTATION=1 \
  -DANDROID_LARGE_MEMORY_DEVICE $(SKIA_DEFS) \
  -I$(QNX_INC) -I$(QNX_INC)/freetype2 -I$(CORE_ROOT)/include -I$(CORE_ROOT)/liblog/include

build/skia/%.o: $(SKIA)/%.cpp
	@mkdir -p $(dir $@)
	$(CXX) $(SKIA_CFLAGS) -c $< -o $@ 2> $@.err || { echo "FAILED: $<"; tail -12 $@.err; false; }

skia: $(SKIA_OBJS)

JAVACORE_OBJS += $(SKIA_OBJS)
# Static libpng from the sysroot (1.4.11); its zlib resolves from libart.
JAVACORE_EXTRA_LIBS += $(ICU_LIBS)/libpngS.a

# graphics_facade.cc draws through Skia now: it needs the Skia headers and the
# SK_BUILD_FOR_ANDROID define (SkPreConfig picks the platform). Accumulates
# with the -O2 the P1 rule already puts on this object.
build/javacore/graphics_facade.o: JCFLAGS += $(SKIA_DEFS)
