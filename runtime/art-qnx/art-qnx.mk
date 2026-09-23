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

<<<<<<< HEAD
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
=======
# arm32 only: drop the other architecture trees and the per-OS files
# (shell grep; make filter-out cannot match these patterns here). The QNX
# variants (os_qnx.cc, thread_qnx.cc) replace the excluded ones.
RUNTIME_SRCS := $(filter-out %_test.cc,$(shell find $(ART_ROOT)/runtime -name "*.cc" \
                | grep -v "/arch/arm64/" | grep -v "/arch/mips/" \
                | grep -v "/arch/mips64/" | grep -v "/arch/x86/" \
                | grep -v "/arch/x86_64/" \
                | grep -v "/runtime_android.cc" | grep -v "/runtime_linux.cc" \
                | grep -v "/os_linux.cc" \
                | grep -v "/thread_linux.cc" | grep -v "/thread_android.cc" \
                | grep -v "/monitor_android.cc" | grep -v "/monitor_linux.cc"))
# our own QNX replacements
RUNTIME_SRCS += $(abspath src/os_qnx.cc) $(abspath src/thread_qnx.cc) \
                $(abspath src/debug_operators.cc) $(abspath src/zip_stubs.cc) \
                $(abspath src/native_bridge_stubs.cc) $(abspath src/atrace_stubs.cc) \
                $(abspath src/log_stubs.cc) $(abspath src/backtrace_stubs.cc) \
                $(abspath src/arch_features_stubs.cc) $(abspath src/runtime_qnx.cc) \
                $(abspath src/misc_stubs.cc)

# qnx_shims proc.c (qnx_tgkill)
SHIM_PROCS := build/support/qnx_shims/proc.o
SHIM_PROCS_SRC := $(SHIMS)/qnx-shims/proc.c

# zlib (QNX sysroot has no zlib; check_jni needs adler32)
ZLIB_ROOT ?= $(abspath ../../zlib)
ZLIB_SRCS := $(filter-out %test.c %gzlog.c,$(wildcard $(ZLIB_ROOT)/src/*.c))
ZLIB_OBJS := $(patsubst $(ZLIB_ROOT)/src/%.c,build/zlib/%.o,$(ZLIB_SRCS))

# supporting sources from sibling trees
SUPPORT_SRCS := $(ART_ROOT)/sigchainlib/sigchain.cc \
                $(LIBNATIVE)/JNIHelp.cpp \
                $(LIBNATIVE)/JniConstants.cpp \
                $(LIBNATIVE)/toStringArray.cpp \
                $(CORE_ROOT)/libcutils/process_name.c
SUPPORT_OBJS := $(patsubst $(ART_ROOT)/%.cc,build/support/%.o,$(filter $(ART_ROOT)/%,$(SUPPORT_SRCS))) \
                $(patsubst $(LIBNATIVE)/%.cpp,build/support/%.o,$(filter $(LIBNATIVE)/%,$(SUPPORT_SRCS))) \
                $(patsubst $(CORE_ROOT)/%.c,build/support/%.o,$(filter $(CORE_ROOT)/%,$(SUPPORT_SRCS)))

# ARM assembly entrypoints (Linux syntax; assembled with gcc)
ARM_ASM := $(abspath $(ART_ROOT)/runtime/arch/arm/asm_support_arm.S) \
           $(abspath $(ART_ROOT)/runtime/arch/arm/jni_entrypoints_arm.S) \
           $(abspath $(ART_ROOT)/runtime/arch/arm/memcmp16_arm.S) \
           $(abspath $(ART_ROOT)/runtime/arch/arm/quick_entrypoints_arm.S) \
           $(abspath $(ART_ROOT)/runtime/arch/arm/instruction_set_features_assembly_tests.S)
ARM_ASM_OBJS := $(patsubst $(ART_ROOT)/%,build/%,$(ARM_ASM:.S=.o))

SRC_OBJS := build/src/os_qnx.o build/src/thread_qnx.o build/src/debug_operators.o \
            build/src/zip_stubs.o build/src/native_bridge_stubs.o \
            build/src/atrace_stubs.o build/src/log_stubs.o \
            build/src/backtrace_stubs.o build/src/arch_features_stubs.o \
            build/src/runtime_qnx.o build/src/misc_stubs.o

RUNTIME_OBJS := $(patsubst $(ART_ROOT)/%.cc,build/%.o,$(filter-out $(abspath src)/%,$(RUNTIME_SRCS))) \
                $(SRC_OBJS)

all: $(RUNTIME_OBJS) $(ARM_ASM_OBJS) $(ZLIB_OBJS) $(SUPPORT_OBJS) $(SHIM_PROCS)

# link attempt: surfaces undefined symbols
libart.so: $(RUNTIME_OBJS) $(ARM_ASM_OBJS) $(ZLIB_OBJS) $(SUPPORT_OBJS) $(SHIM_PROCS)
	$(CXX) -shared -o $@ $^ -Wl,--no-undefined 2>&1 | grep -vE "DWARF error" | head -60

build/zlib/%.o: $(ZLIB_ROOT)/src/%.c
	@mkdir -p $(dir $@)
	$(CC) -O2 -I$(ZLIB_ROOT) -c $< -o $@ 2> $(patsubst %.o,%.err,$@) || { echo "FAILED: $<"; tail -12 $(patsubst %.o,%.err,$@); }

# sigchain (C++, art flags), libnativehelper (C++, art flags), libcutils (C)
build/support/%.o: $(ART_ROOT)/%.cc
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -c $< -o $@ 2> $(patsubst %.o,%.err,$@) || { echo "FAILED: $<"; tail -12 $(patsubst %.o,%.err,$@); }

build/support/%.o: $(LIBNATIVE)/%.cpp
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -c $< -o $@ 2> $(patsubst %.o,%.err,$@) || { echo "FAILED: $<"; tail -12 $(patsubst %.o,%.err,$@); }

build/support/%.o: $(CORE_ROOT)/%.c
	@mkdir -p $(dir $@)
	$(CC) -O2 -I$(CORE_ROOT)/include -c $< -o $@ 2> $(patsubst %.o,%.err,$@) || { echo "FAILED: $<"; tail -12 $(patsubst %.o,%.err,$@); }
>>>>>>> 6e0a8006 (Complete ART 6.0.1 QNX port: full runtime compiles and links as libart.so)

check:
	@mkdir -p build
	$(CXX) $(CXXFLAGS) -c $(ART_ROOT)/runtime/base/mutex.cc -o build/mutex_check.o

<<<<<<< HEAD
all: $(RUNTIME_OBJS)

=======
>>>>>>> 6e0a8006 (Complete ART 6.0.1 QNX port: full runtime compiles and links as libart.so)
build/%.o: $(ART_ROOT)/%.cc
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -c $< -o $@ 2> $(patsubst %.o,%.err,$@) || { echo "FAILED: $<"; tail -12 $(patsubst %.o,%.err,$@); }

<<<<<<< HEAD
=======
build/src/%.o: src/%.cc
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -c $< -o $@ 2> $(patsubst %.o,%.err,$@) || { echo "FAILED: $<"; tail -12 $(patsubst %.o,%.err,$@); }

# ARM .S files are stored under build/<art-relpath>; no C++ flags, no
# force-included compat header
build/%.o: $(ART_ROOT)/%.S
	@mkdir -p $(dir $@)
	$(CXX) -x assembler-with-cpp -DART_TARGET -DART_DEFAULT_GC_TYPE_IS_CMS \
	  $(filter -I%,$(CXXFLAGS)) $(filter -D%,$(CXXFLAGS)) \
	  -c $< -o $@ 2> $(patsubst %.o,%.err,$@) || { echo "FAILED: $<"; tail -12 $(patsubst %.o,%.err,$@); }

>>>>>>> 6e0a8006 (Complete ART 6.0.1 QNX port: full runtime compiles and links as libart.so)
patches:
	cd $(ART_ROOT) && for p in $(SHIMS)/patches/*.patch; do patch -p1 -N < $$p || true; done

clean:
	rm -rf build
<<<<<<< HEAD
=======

$(SHIM_PROCS): $(SHIM_PROCS_SRC)
	@mkdir -p $(dir $@)
	$(CC) -O2 -I$(SHIMS)/qnx-shims -c $< -o $@

>>>>>>> 6e0a8006 (Complete ART 6.0.1 QNX port: full runtime compiles and links as libart.so)
