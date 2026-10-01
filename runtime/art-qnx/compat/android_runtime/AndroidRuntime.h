/*
 * QNX port stub: the framework JNI files include <android_runtime/AndroidRuntime.h>
 * via core_jni_helpers.h. The real header drags in binder and half of libutils.
 * Only registerNativeMethods is used; it is implemented in
 * src/android_runtime_stubs.cc on top of JNIHelp.
 */
#ifndef _RUNTIME_ANDROID_RUNTIME_H
#define _RUNTIME_ANDROID_RUNTIME_H

#include <jni.h>
#include <log/log.h>  // LOG_ALWAYS_FATAL_IF used by core_jni_helpers.h

namespace android {

class AndroidRuntime {
 public:
  static int registerNativeMethods(JNIEnv* env, const char* className,
                                   const JNINativeMethod* gMethods,
                                   int numMethods);
};

}  // namespace android

#endif  // _RUNTIME_ANDROID_RUNTIME_H
