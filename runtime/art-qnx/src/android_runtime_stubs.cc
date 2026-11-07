/*
 * QNX port: AndroidRuntime::registerNativeMethods on top of JNIHelp, and
 * getJNIEnv through the one created VM.
 */
#include <android_runtime/AndroidRuntime.h>

#include "JNIHelp.h"

namespace android {

int AndroidRuntime::registerNativeMethods(JNIEnv* env, const char* className,
                                          const JNINativeMethod* gMethods,
                                          int numMethods) {
  return jniRegisterNativeMethods(env, className, gMethods, numMethods);
}

// One VM per process; null when the calling thread is not attached, as stock.
JNIEnv* AndroidRuntime::getJNIEnv() {
  JavaVM* vm;
  jsize n;
  JNIEnv* env;
  if (JNI_GetCreatedJavaVMs(&vm, 1, &n) != JNI_OK || n == 0) return nullptr;
  return vm->GetEnv(reinterpret_cast<void**>(&env), JNI_VERSION_1_4) == JNI_OK ? env : nullptr;
}

}  // namespace android
