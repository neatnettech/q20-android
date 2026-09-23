/*
 * libjavacore QNX subset registration.
 *
 * ponytail: only the native tables needed to get through runtime boot and
 * a hello world are registered. ICU, crypto, regex, zip, and expat natives
 * land with the framework milestone (their classes are not touched by the
 * interpreter milestone).
 */

#define LOG_TAG "libcore"

#include <jni.h>

extern void register_android_system_OsConstants(JNIEnv*);
extern void register_java_io_File(JNIEnv*);
extern void register_java_io_FileDescriptor(JNIEnv*);
extern void register_java_lang_System(JNIEnv*);
extern void register_libcore_io_Memory(JNIEnv*);
extern void register_libcore_io_Posix(JNIEnv*);

jint JNI_OnLoad(JavaVM* vm, void*) {
    JNIEnv* env;
    if (vm->GetEnv(reinterpret_cast<void**>(&env), JNI_VERSION_1_6) != JNI_OK) {
        abort();
    }
    register_android_system_OsConstants(env);
    register_java_io_File(env);
    register_java_io_FileDescriptor(env);
    register_java_lang_System(env);
    register_libcore_io_Memory(env);
    register_libcore_io_Posix(env);
    return JNI_VERSION_1_6;
}
