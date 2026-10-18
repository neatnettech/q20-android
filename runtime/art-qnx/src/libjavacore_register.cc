/*
 * libjavacore QNX subset registration.
 *
 * ponytail: only the native tables the A ladder has reached are registered.
 * The UTF-8 charset lookup is a stub (src/icu_stubs.cc) because
 * System.out.println calls it on the boot path. Crypto, zip and expat natives
 * land when something reaches them.
 */

#define LOG_TAG "libcore"

#include <jni.h>

#include "ScopedLocalFrame.h"

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
extern void register_libcore_icu_ICU(JNIEnv*);
extern void register_java_lang_Character(JNIEnv*);
extern void register_java_lang_Float(JNIEnv*);
extern void register_java_lang_Double(JNIEnv*);
extern void register_qnx_android_os(JNIEnv*);
extern void register_qnx_graphics(JNIEnv*);
namespace android {
extern void register_android_util_Log(JNIEnv*);
extern void register_android_os_Parcel(JNIEnv*);
extern void register_android_os_SystemClock(JNIEnv*);
extern int register_android_os_SystemProperties(JNIEnv*);
extern int register_android_content_AssetManager(JNIEnv*);
extern int register_android_content_StringBlock(JNIEnv*);
extern int register_android_content_XmlBlock(JNIEnv*);
extern int register_android_os_MessageQueue(JNIEnv*);
extern int register_android_animation_PropertyValuesHolder(JNIEnv*);
}  // namespace android

jint JNI_OnLoad(JavaVM* vm, void*) {
    JNIEnv* env;
    if (vm->GetEnv(reinterpret_cast<void**>(&env), JNI_VERSION_1_6) != JNI_OK) {
        abort();
    }
    // Stock register functions leak FindClass locals (patch 0090 history) and
    // ART on QNX checks the main thread's table at exit; one frame covers all.
    ScopedLocalFrame frame(env);
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
    android::register_android_os_Parcel(env);
    android::register_android_os_SystemClock(env);
    register_libcore_icu_ICU(env);
    register_java_lang_Character(env);
    // AOT code inlines these as intrinsics; -Xint calls the natives.
    register_java_lang_Float(env);
    register_java_lang_Double(env);
    android::register_android_os_SystemProperties(env);
    android::register_android_content_AssetManager(env);
    android::register_android_content_StringBlock(env);
    android::register_android_content_XmlBlock(env);
    android::register_android_os_MessageQueue(env);
    register_qnx_android_os(env);
    android::register_android_animation_PropertyValuesHolder(env);
    register_qnx_graphics(env);
    return JNI_VERSION_1_6;
}
