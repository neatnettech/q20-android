/*
 * libjavacore QNX subset registration.
 *
 * ponytail: only the native tables the A ladder has reached are registered.
 * Charsets are the real NativeConverter on the sysroot ICU 4.6 (patch 0103);
 * System.out.println reaches charsetForName on the boot path. Crypto, zip and
 * expat natives land when something reaches them.
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
extern void register_libcore_icu_NativeConverter(JNIEnv*);
extern void register_java_lang_Math(JNIEnv*);
extern void register_java_util_regex_Pattern(JNIEnv*);
extern void register_java_util_regex_Matcher(JNIEnv*);
extern void register_libcore_icu_ICU(JNIEnv*);
extern void register_libcore_io_AsynchronousCloseMonitor(JNIEnv*);
extern void register_java_lang_Character(JNIEnv*);
extern void register_java_lang_Float(JNIEnv*);
extern void register_java_lang_Double(JNIEnv*);
extern void register_java_lang_StringToReal(JNIEnv*);
extern void register_java_lang_RealToString(JNIEnv*);
extern void register_qnx_android_os(JNIEnv*);
extern void register_qnx_graphics(JNIEnv*);
extern void register_java_nio_ByteOrder(JNIEnv*);
extern int register_android_graphics_Graphics(JNIEnv*);
extern int register_android_graphics_Bitmap(JNIEnv*);
extern int register_android_graphics_BitmapFactory(JNIEnv*);
extern int register_android_graphics_NinePatch(JNIEnv*);
namespace android {
extern void register_android_util_Log(JNIEnv*);
extern int register_android_util_EventLog(JNIEnv*);
extern void register_android_os_Parcel(JNIEnv*);
extern void register_android_os_SystemClock(JNIEnv*);
extern int register_android_os_SystemProperties(JNIEnv*);
extern int register_android_content_AssetManager(JNIEnv*);
extern int register_android_content_StringBlock(JNIEnv*);
extern int register_android_content_XmlBlock(JNIEnv*);
extern int register_android_os_MessageQueue(JNIEnv*);
extern int register_android_animation_PropertyValuesHolder(JNIEnv*);
extern int register_android_view_MotionEvent(JNIEnv*);
extern int register_android_view_VelocityTracker(JNIEnv*);
extern int register_android_view_KeyEvent(JNIEnv*);
extern int register_android_view_KeyCharacterMap(JNIEnv*);
extern int register_android_text_AndroidBidi(JNIEnv*);
extern int register_android_graphics_Matrix(JNIEnv*);
extern int register_android_database_CursorWindow(JNIEnv*);
extern int register_android_database_SQLiteConnection(JNIEnv*);
extern int register_android_database_SQLiteGlobal(JNIEnv*);
extern int register_android_database_SQLiteDebug(JNIEnv*);
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
    register_java_nio_ByteOrder(env);
    register_libcore_icu_NativeConverter(env);
    register_java_lang_Math(env);
    register_java_util_regex_Pattern(env);
    register_java_util_regex_Matcher(env);
    android::register_android_util_Log(env);
    android::register_android_util_EventLog(env);  // Activity.onMenuItemSelected
    android::register_android_os_Parcel(env);
    android::register_android_os_SystemClock(env);
    register_libcore_icu_ICU(env);
    // FileInputStream.close() calls it; missing it kills any Java file IO
    // (found 2026-11-06 by the A8 input poll dying on stream close).
    register_libcore_io_AsynchronousCloseMonitor(env);
    register_java_lang_Character(env);
    // AOT code inlines these as intrinsics; -Xint calls the natives.
    register_java_lang_Float(env);
    register_java_lang_Double(env);
    // Double.parseDouble and Double.toString slow paths (A9: the Calculator).
    register_java_lang_StringToReal(env);
    register_java_lang_RealToString(env);
    android::register_android_os_SystemProperties(env);
    android::register_android_content_AssetManager(env);
    android::register_android_content_StringBlock(env);
    android::register_android_content_XmlBlock(env);
    android::register_android_os_MessageQueue(env);
    register_qnx_android_os(env);
    android::register_android_animation_PropertyValuesHolder(env);
    // Stock bitmaps and matrices under the facade: decode (PNG, 9-patch),
    // Bitmap, and the SkMatrix the facade Canvas concats. Ahead of the facade,
    // whose NinePatch draws (on its own canvas handle) override the stock glue.
    register_android_graphics_Graphics(env);
    register_android_graphics_Bitmap(env);
    register_android_graphics_BitmapFactory(env);
    register_android_graphics_NinePatch(env);
    android::register_android_graphics_Matrix(env);
    register_qnx_graphics(env);
    // A9 touch: real MotionEvent dispatch and VelocityTracker (ViewPager).
    android::register_android_view_MotionEvent(env);
    android::register_android_view_VelocityTracker(env);
    // NOD-33: real key events for text fields (KCM via libinput).
    android::register_android_view_KeyEvent(env);
    android::register_android_view_KeyCharacterMap(env);
    // MeasuredText asks for bidi levels once a char is at or above U+0590.
    android::register_android_text_AndroidBidi(env);
    // NOD-22: SQLiteDatabase and the cursors a ContentProvider hands back.
    android::register_android_database_CursorWindow(env);
    android::register_android_database_SQLiteConnection(env);
    android::register_android_database_SQLiteGlobal(env);
    android::register_android_database_SQLiteDebug(env);
    return JNI_VERSION_1_6;
}
