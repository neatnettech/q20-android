# ART 6.0.1 for QNX armle-v7 build scaffold.
#
# Iterative port: compiles the AOSP ART runtime sources with the QNX cross
# toolchain, QNX libc, and AOSP headers. Each translation unit is expected
# to need porting fixes; the flow is compile -> fix -> repeat.
#
# Usage (inside the toolchain env, see toolchains/playbook-gcc9/env.sh):
#   make -f art-qnx.mk check          # compile one file, show first errors
#   make -f art-qnx.mk                # build all objects (iterate on errors)
#
# Patches to the AOSP tree live in runtime/patches/ and are applied by
#   make -f art-qnx.mk patches

ART_ROOT    ?= $(abspath ../../art)
CORE_ROOT   ?= $(abspath ../../system/core)
LIBNATIVE   ?= $(abspath ../../libnativehelper)
SHIMS       ?= $(abspath ..)

CXXFLAGS := -O0 -g -std=gnu++11 -fno-rtti -fno-exceptions \
  -DART_TARGET -DART_DEFAULT_GC_TYPE_IS_CMS -DIMT_SIZE=64 \
  -DART_BASE_ADDRESS=0x70000000 \
  -DART_BASE_ADDRESS_MIN_DELTA=-0x1000000 -DART_BASE_ADDRESS_MAX_DELTA=0x1000000 \
  -DBUILDING_LIBART \
  -include $(abspath compat/art_qnx_compat.h) \
  -Wno-unused-parameter -Wno-sign-compare -Wno-missing-field-initializers \
  -I$(ART_ROOT)/runtime -I$(ART_ROOT) \
  -I$(ART_ROOT)/cmdline -I$(ART_ROOT)/sigchainlib \
  -I$(CORE_ROOT)/include -I$(CORE_ROOT)/liblog/include \
  -I$(LIBNATIVE)/include/nativehelper \
  -I$(SHIMS)/qnx-shims

# header shims shadow missing linux-style headers
CXXFLAGS += -I$(abspath compat)

# arm32 only: drop the other architecture trees (shell grep; make
# filter-out cannot match multi-% middle patterns here)
RUNTIME_SRCS := $(filter-out %_test.cc,$(shell find $(ART_ROOT)/runtime -name "*.cc" \
                | grep -v "/arch/arm64/" | grep -v "/arch/mips/" \
                | grep -v "/arch/mips64/" | grep -v "/arch/x86/" \
                | grep -v "/arch/x86_64/"))
# exclude per-OS files; the QNX variants (os_qnx.cc, thread_qnx.cc,
# monitor_qnx.cc) will replace them
RUNTIME_SRCS := $(filter-out %/runtime_android.cc %/runtime_linux.cc \
                %/thread_linux.cc %/monitor_android.cc %/monitor_linux.cc, \
                $(RUNTIME_SRCS))

RUNTIME_OBJS := $(patsubst $(ART_ROOT)/%.cc,build/%.o,$(RUNTIME_SRCS))

check:
	@mkdir -p build
	$(CXX) $(CXXFLAGS) -c $(ART_ROOT)/runtime/base/mutex.cc -o build/mutex_check.o

all: $(RUNTIME_OBJS)

build/%.o: $(ART_ROOT)/%.cc
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -c $< -o $@ 2> $(patsubst %.o,%.err,$@) || { echo "FAILED: $<"; tail -12 $(patsubst %.o,%.err,$@); }

patches:
	cd $(ART_ROOT) && for p in $(SHIMS)/patches/*.patch; do patch -p1 -N < $$p || true; done

clean:
	rm -rf build
