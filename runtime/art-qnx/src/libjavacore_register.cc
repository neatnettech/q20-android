/*
 * libjavacore QNX subset registration.
 *
 * ponytail: only the native tables needed to get through runtime boot and
 * a hello world are registered. The ICU version natives and the UTF-8 charset
 * lookup are stubs (src/icu_stubs.cc) because System.<clinit> and
 * System.out.println call them on the boot path. Crypto, regex, zip and expat
 * natives land with the framework milestone.
 */

#define LOG_TAG "libcore"

#include <jni.h>

extern void register_android_system_OsConstants(JNIEnv*);
extern void register_java_io_File(JNIEnv*);
extern void register_java_io_FileDescriptor(JNIEnv*);
extern void register_java_lang_System(JNIEnv*);
extern void register_libcore_io_Memory(JNIEnv*);
extern void register_libcore_io_Posix(JNIEnv*);
extern void register_qnx_icu_stubs(JNIEnv*);
extern void register_java_lang_Math(JNIEnv*);
extern void register_java_util_regex_Pattern(JNIEnv*);
extern void register_java_util_regex_Matcher(JNIEnv*);
namespace android {
extern void register_android_util_Log(JNIEnv*);
extern void register_android_os_SystemClock(JNIEnv*);
}  // namespace android

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
    register_qnx_icu_stubs(env);
    register_java_lang_Math(env);
    register_java_util_regex_Pattern(env);
    register_java_util_regex_Matcher(env);
    android::register_android_util_Log(env);
    android::register_android_os_SystemClock(env);
    return JNI_VERSION_1_6;
}
