/*
 * QNX port: AndroidRuntime::registerNativeMethods on top of JNIHelp.
 */
#include <android_runtime/AndroidRuntime.h>

#include "JNIHelp.h"

namespace android {

int AndroidRuntime::registerNativeMethods(JNIEnv* env, const char* className,
                                          const JNINativeMethod* gMethods,
                                          int numMethods) {
  return jniRegisterNativeMethods(env, className, gMethods, numMethods);
}

}  // namespace android
