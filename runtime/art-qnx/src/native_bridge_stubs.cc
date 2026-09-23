/*
 * QNX port: native bridge stubs.
 *
 * ponytail: no native bridge (Houdini etc.) on QNX. Everything fails/off.
 */

#include <nativebridge/native_bridge.h>

namespace android {

bool LoadNativeBridge(const char* native_bridge_library_filename,
                      const NativeBridgeRuntimeCallbacks* runtime_callbacks) {
  (void)native_bridge_library_filename;
  (void)runtime_callbacks;
  return false;
}

bool PreInitializeNativeBridge(const char* app_data_dir, const char* instruction_set) {
  (void)app_data_dir;
  (void)instruction_set;
  return false;
}

bool InitializeNativeBridge(JNIEnv* env, const char* instruction_set) {
  (void)env;
  (void)instruction_set;
  return false;
}

void UnloadNativeBridge() {
}

uint32_t NativeBridgeGetVersion() {
  return 0;
}

NativeBridgeSignalHandlerFn NativeBridgeGetSignalHandler(int signal) {
  (void)signal;
  return nullptr;
}

void* NativeBridgeGetTrampoline(void* handle, const char* name, const char* shorty,
                                uint32_t len) {
  (void)handle;
  (void)name;
  (void)shorty;
  (void)len;
  return nullptr;
}

bool NativeBridgeIsSupported(const char* instruction_set) {
  (void)instruction_set;
  return false;
}

void* NativeBridgeLoadLibrary(const char* libpath, int flag) {
  (void)libpath;
  (void)flag;
  return nullptr;
}

}  // namespace android
