/*
 * QNX port: libjavacore stub.
 *
 * ponytail: registers no natives; ART only needs JNI_OnLoad to succeed at
 * startup. Add the real native method tables (System, Runtime, File, ...)
 * as the run progresses and each class's registerNatives path is reached.
 */

#include <jni.h>

extern "C" JNIEXPORT jint JNI_OnLoad(JavaVM* vm, void* reserved) {
  (void)vm;
  (void)reserved;
  return JNI_VERSION_1_6;
}
