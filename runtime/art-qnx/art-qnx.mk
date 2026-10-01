# ART 6.0.1 for QNX armle-v7 build scaffold.
#
# Iterative port: compiles the AOSP ART runtime sources with the QNX cross
# toolchain, QNX libc, and AOSP headers. Each translation unit is expected
# to need porting fixes; the flow is compile -> fix -> repeat.
#
# Usage (inside the toolchain env, see toolchains/playbook-gcc9/env.sh):
#   make -f art-qnx.mk check          # compile one file, show first errors
#   make -f art-qnx.mk -k             # build all objects, keep going on errors
#   make -f art-qnx.mk                # build all objects, stop at the first error
#
# Patches to the AOSP tree live in runtime/patches/ and are applied by
#   make -f art-qnx.mk patches

ART_ROOT    ?= $(abspath ../../art)
CORE_ROOT   ?= $(abspath ../../system/core)
LIBNATIVE   ?= $(abspath ../../libnativehelper)
SHIMS       ?= $(abspath ..)

CXXFLAGS := -O0 -g -std=gnu++11 -fno-rtti -fno-exceptions -DNDEBUG \
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
CXXFLAGS += -I$(abspath compat) -I$(ART_ROOT)/compiler

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
                $(abspath src/alloc_debug.cc) \
                $(abspath src/debug_operators.cc) \
                $(abspath src/native_bridge_stubs.cc) $(abspath src/atrace_stubs.cc) \
                $(abspath src/log_stubs.cc) $(abspath src/backtrace_stubs.cc) \
                $(abspath src/arch_features_stubs.cc) $(abspath src/runtime_qnx.cc) \
                $(abspath src/misc_stubs.cc)

# real libziparchive (APK support), replacing the zip stubs: the C API
# implementation from system/core plus its FileMap and libbase file deps.
ZIP_ROOT ?= $(abspath ../../system/core)
ZIP_SRCS := $(ZIP_ROOT)/libziparchive/zip_archive.cc \
            $(ZIP_ROOT)/libutils/FileMap.cpp \
            $(ZIP_ROOT)/base/file.cpp
ZIP_OBJS := $(patsubst $(ZIP_ROOT)/%.cc,build/zip/%.o,$(filter %.cc,$(ZIP_SRCS))) \
            $(patsubst $(ZIP_ROOT)/%.cpp,build/zip/%.o,$(filter %.cpp,$(ZIP_SRCS)))
# no force-included art compat header for system/core code; a small QNX
# madvise shim instead
ZIPFLAGS := $(filter-out -include,$(filter-out $(abspath compat/art_qnx_compat.h),$(CXXFLAGS))) \
            -include $(abspath compat/qnx_zip_compat.h) \
            -I$(ZIP_ROOT)/libziparchive/include -I$(ZIP_ROOT)/base/include \
            -I$(ZIP_ROOT)/include -I$(ZIP_ROOT)/liblog/include \
            -I$(ZIP_ROOT)/libcutils/include

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

SRC_OBJS := build/src/os_qnx.o build/src/thread_qnx.o build/src/alloc_debug.o \
            build/src/debug_operators.o \
            build/src/native_bridge_stubs.o \
            build/src/atrace_stubs.o build/src/log_stubs.o \
            build/src/backtrace_stubs.o build/src/arch_features_stubs.o \
            build/src/runtime_qnx.o build/src/misc_stubs.o

RUNTIME_OBJS := $(patsubst $(ART_ROOT)/%.cc,build/%.o,$(filter-out $(abspath src)/%,$(RUNTIME_SRCS))) \
                $(SRC_OBJS)

.PHONY: all stage patches clean check

all: $(RUNTIME_OBJS) $(ARM_ASM_OBJS) $(ZLIB_OBJS) $(SUPPORT_OBJS) $(ZIP_OBJS) $(SHIM_PROCS)

# link attempt: surfaces undefined symbols
libart.so: $(RUNTIME_OBJS) $(ARM_ASM_OBJS) $(ZLIB_OBJS) $(SUPPORT_OBJS) $(ZIP_OBJS) $(SHIM_PROCS)
	@mkdir -p build
	$(CXX) -shared -o $@ $^ -Wl,--no-undefined > build/link-libart.log 2>&1 \
	  || { grep -vE "DWARF error" build/link-libart.log | head -60; false; }

# libjavacore subset (native methods needed for runtime boot + hello world)
LIBCORE_NATIVE ?= $(abspath ../../libcore/luni/src/main/native)
JAVACORE_SRCS := android_system_OsConstants.cpp java_io_File.cpp \
                 java_io_FileDescriptor.cpp java_lang_System.cpp \
                 libcore_io_Memory.cpp libcore_io_Posix.cpp \
                 AsynchronousCloseMonitor.cpp ExecStrings.cpp JniException.cpp \
                 NetworkUtilities.cpp canonicalize_path.cpp readlink.cpp \
                 valueOf.cpp libcore_io_AsynchronousCloseMonitor.cpp
JAVACORE_OBJS := $(patsubst %.cpp,build/javacore/%.o,$(JAVACORE_SRCS))
JAVACORE_OBJS += build/javacore/register.o build/javacore/icu_stubs.o
JAVACORE_OBJS += build/javacore/JNIHelp.o \
                 build/javacore/toStringArray.o build/javacore/fallocate.o \
                 build/javacore/sendfile.o build/javacore/gcc_frame_stubs.o

libjavacore.so: $(JAVACORE_OBJS)
	@mkdir -p build
	$(CXX) -shared -o $@ $^ > build/link-libjavacore.log 2>&1 \
	  || { grep -vE "DWARF error" build/link-libjavacore.log | head -20; false; }

build/javacore/%.o: $(LIBCORE_NATIVE)/%.cpp
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -Wno-error=format -I$(LIBCORE_NATIVE) -I$(abspath ../../libcore/include) -c $< -o $@ 2> $@.err || { echo "FAILED: $<"; tail -12 $@.err; false; }

build/javacore/register.o: src/libjavacore_register.cc
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -I$(LIBCORE_NATIVE) -I$(abspath ../../libcore/include) -c $< -o $@ 2> $@.err || { echo "FAILED: $<"; tail -12 $@.err; false; }

build/javacore/icu_stubs.o: src/icu_stubs.cc
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -I$(LIBCORE_NATIVE) -I$(abspath ../../libcore/include) -c $< -o $@ 2> $@.err || { echo "FAILED: $<"; tail -12 $@.err; false; }

build/javacore/JNIHelp.o: $(LIBNATIVE)/JNIHelp.cpp
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -c $< -o $@ 2> $@.err || { echo "FAILED: $<"; tail -12 $@.err; false; }

build/javacore/toStringArray.o: $(LIBNATIVE)/toStringArray.cpp
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -c $< -o $@ 2> $@.err || { echo "FAILED: $<"; tail -12 $@.err; false; }

build/javacore/fallocate.o: src/fallocate.c
	@mkdir -p $(dir $@)
	$(CC) -O2 -c $< -o $@ 2> $@.err || { echo "FAILED: $<"; tail -12 $@.err; false; }

build/javacore/sendfile.o: src/sendfile_qnx.c
	@mkdir -p $(dir $@)
	$(CC) -O2 -c $< -o $@ 2> $@.err || { echo "FAILED: $<"; tail -12 $@.err; false; }

build/javacore/gcc_frame_stubs.o: src/gcc_frame_stubs.cc
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -c $< -o $@ 2> $@.err || { echo "FAILED: $<"; tail -12 $@.err; false; }


# The interpreter must be optimized even in this -O0 bring-up build: at -O0
# ExecuteGotoImpl gets a ~17KB stack frame per invocation, which overflows the
# small stacks QNX actually grants threads (the request via
# pthread_attr_setstacksize is capped around 1MB, observed 128KB for attached
# threads). AOSP always builds these files at -O2 (q20-android).
build/runtime/interpreter/%.o: $(ART_ROOT)/runtime/interpreter/%.cc
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -O2 -c $< -o $@ 2> $(patsubst %.o,%.err,$@) || { echo "FAILED: $<"; tail -12 $(patsubst %.o,%.err,$@); false; }

# ---- ART compiler (Quick backend, arm32 only) ----
COMPILER_SRCS := $(filter-out %_test.cc,$(shell find $(ART_ROOT)/compiler -name "*.cc" \
                  | grep -v "/optimizing/" | grep -v "/jit/" \
                  | grep -v "/quick/arm64/" | grep -v "/quick/mips/" \
                  | grep -v "/quick/x86/" | grep -v "/quick/x86_64/" \
                  | grep -v "/portable/" | grep -v "/arm64/" | grep -v "/mips/" \
                  | grep -v "/mips64/" | grep -v "/x86/" | grep -v "/x86_64/" \
                  | grep -v "/linker/x86/" | grep -v "/linker/x86_64/" \
                  | grep -v "/trampolines/.*_test" \
                  | grep -v "common_compiler_test"))
COMPILER_OBJS := $(patsubst $(ART_ROOT)/%,build/%,$(COMPILER_SRCS:.cc=.o))

# dex2oat executable
DEX2OAT_OBJS := build/dex2oat/dex2oat.o
dex2oat: $(DEX2OAT_OBJS) libart.so $(COMPILER_OBJS)
	@mkdir -p build
	$(CXX) -o $@ $(DEX2OAT_OBJS) $(COMPILER_OBJS) -L. -lart \
	  -Wl,-z,stack-size=0x800000 > build/link-dex2oat.log 2>&1 \
	  || { grep -vE "DWARF error" build/link-dex2oat.log | head -30; false; }

build/dex2oat/dex2oat.o: $(ART_ROOT)/dex2oat/dex2oat.cc
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -c $< -o $@ 2> $@.err || { echo "FAILED: $<"; tail -12 $@.err; false; }

# compiler objects (same flags as runtime)
build/compiler/%.o: $(ART_ROOT)/compiler/%.cc
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -c $< -o $@ 2> $(patsubst %.o,%.err,$@) || { echo "FAILED: $<"; tail -12 $(patsubst %.o,%.err,$@); false; }

# dalvikvm executable: ART launcher, dlopens libart.so via JniInvocation
dalvikvm: build/src/dalvikvm.o build/src/jni_invocation.o libart.so
	$(CXX) -o $@ build/src/dalvikvm.o build/src/jni_invocation.o \
	  -L. -lart -Wl,-rpath,/proc/boot:/usr/lib \
	  2>&1 | grep -vE "DWARF error" | head -20

build/src/dalvikvm.o: $(ART_ROOT)/dalvikvm/dalvikvm.cc
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -c $< -o $@ 2> $@.err || { echo "FAILED: $<"; tail -12 $@.err; false; }

build/src/jni_invocation.o: $(LIBNATIVE)/JniInvocation.cpp
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -c $< -o $@ 2> $@.err || { echo "FAILED: $<"; tail -12 $@.err; false; }

build/zlib/%.o: $(ZLIB_ROOT)/src/%.c
	@mkdir -p $(dir $@)
	$(CC) -O2 -I$(ZLIB_ROOT) -c $< -o $@ 2> $(patsubst %.o,%.err,$@) || { echo "FAILED: $<"; tail -12 $(patsubst %.o,%.err,$@); false; }

# system/core sources for libziparchive (no art compat header, no -DNDEBUG
# surprises; they compile standalone)
build/zip/%.o: $(ZIP_ROOT)/%.cc
	@mkdir -p $(dir $@)
	$(CXX) $(ZIPFLAGS) -c $< -o $@ 2> $(patsubst %.o,%.err,$@) || { echo "FAILED: $<"; tail -12 $(patsubst %.o,%.err,$@); false; }

build/zip/%.o: $(ZIP_ROOT)/%.cpp
	@mkdir -p $(dir $@)
	$(CXX) $(ZIPFLAGS) -c $< -o $@ 2> $(patsubst %.o,%.err,$@) || { echo "FAILED: $<"; tail -12 $(patsubst %.o,%.err,$@); false; }

# sigchain (C++, art flags), libnativehelper (C++, art flags), libcutils (C)
build/support/%.o: $(ART_ROOT)/%.cc
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -c $< -o $@ 2> $(patsubst %.o,%.err,$@) || { echo "FAILED: $<"; tail -12 $(patsubst %.o,%.err,$@); false; }

build/support/%.o: $(LIBNATIVE)/%.cpp
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -c $< -o $@ 2> $(patsubst %.o,%.err,$@) || { echo "FAILED: $<"; tail -12 $(patsubst %.o,%.err,$@); false; }

build/support/%.o: $(CORE_ROOT)/%.c
	@mkdir -p $(dir $@)
	$(CC) -O2 -I$(CORE_ROOT)/include -c $< -o $@ 2> $(patsubst %.o,%.err,$@) || { echo "FAILED: $<"; tail -12 $(patsubst %.o,%.err,$@); false; }

check:
	@mkdir -p build
	$(CXX) $(CXXFLAGS) -c $(ART_ROOT)/runtime/base/mutex.cc -o build/mutex_check.o

build/%.o: $(ART_ROOT)/%.cc
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -c $< -o $@ 2> $(patsubst %.o,%.err,$@) || { echo "FAILED: $<"; tail -12 $(patsubst %.o,%.err,$@); false; }

build/src/%.o: src/%.cc
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -c $< -o $@ 2> $(patsubst %.o,%.err,$@) || { echo "FAILED: $<"; tail -12 $(patsubst %.o,%.err,$@); false; }

# ARM .S files are stored under build/<art-relpath>; no C++ flags, no
# force-included compat header
build/%.o: $(ART_ROOT)/%.S
	@mkdir -p $(dir $@)
	$(CXX) -x assembler-with-cpp -DART_TARGET -DART_DEFAULT_GC_TYPE_IS_CMS \
	  $(filter -I%,$(CXXFLAGS)) $(filter -D%,$(CXXFLAGS)) \
	  -c $< -o $@ 2> $(patsubst %.o,%.err,$@) || { echo "FAILED: $<"; tail -12 $(patsubst %.o,%.err,$@); false; }

# ---- device staging ----
# Assembles everything the Q20 needs into one directory, ready to copy.
# The factory boot dex "framework.dex:classes2.dex" is renamed: a colon splits
# the boot classpath, so ART cannot take that name.
STAGE_DIR ?= build/stage
DEPLOY    ?= $(abspath ../art6-deploy)

stage: dalvikvm dex2oat libart.so libjavacore.so
	@mkdir -p $(STAGE_DIR)/bin $(STAGE_DIR)/lib $(STAGE_DIR)/boot
	cp dalvikvm dex2oat $(STAGE_DIR)/bin/
	cp libart.so libjavacore.so $(STAGE_DIR)/lib/
	cp $(DEPLOY)/libstdc++.so.6 $(DEPLOY)/libgcc_s.so.1 $(STAGE_DIR)/lib/
	for d in $(DEPLOY)/boot/*.dex; do \
	  case "$$d" in \
	    *"framework.dex:classes2.dex") cp "$$d" $(STAGE_DIR)/boot/framework2.dex ;; \
	    *) cp "$$d" $(STAGE_DIR)/boot/ ;; \
	  esac; \
	done
	cp $(abspath ../hello/hello.dex) $(STAGE_DIR)/
	cp $(abspath ../../frameworks/base/preloaded-classes) $(STAGE_DIR)/
	cp device/run_core.sh $(STAGE_DIR)/
	@echo "staged in $(STAGE_DIR); copy it to the device and run: sh run_core.sh all"

# patch paths are repo relative (a/art/..., a/libcore/..., a/system/core/...);
# skip patches already applied, stop on any real reject
patches:
	cd $(abspath ../..) && for p in $(SHIMS)/patches/*.patch; do \
	  if patch -p1 -R -s -f --dry-run < $$p > /dev/null 2>&1; then echo "already applied: $$p"; \
	  else patch -p1 -N < $$p || exit 1; fi; \
	done

clean:
	rm -rf build

$(SHIM_PROCS): $(SHIM_PROCS_SRC)
	@mkdir -p $(dir $@)
	$(CC) -O2 -I$(SHIMS)/qnx-shims -c $< -o $@

