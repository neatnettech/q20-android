/*
 * QNX stand ins for the android.os pieces that sit on top of bionic and the
 * Android property service.
 *
 * Properties: QNX has no property service. property_get and property_set
 * (libcutils API, used by android_os_SystemProperties.cpp) work on a map
 * loaded once from $ANDROID_ROOT/build.prop, plain key=value lines with
 * comments on their own lines.
 *
 * ponytail: set() lives in this process's memory only, no persistence and no
 * change callbacks. A property service resmgr when a second process must see
 * a set().
 *
 * Binder: the Java side statics every Looper, Handler and IFoo.Stub touches.
 * There is no binder driver and no IPC, so the caller is always this process.
 * Trace: tracing is off, so only the enabled tag query is reached.
 */
#include <cutils/properties.h>
#include <utils/misc.h>

#include "JNIHelp.h"

#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <map>
#include <string>

static pthread_mutex_t gPropLock = PTHREAD_MUTEX_INITIALIZER;
static std::map<std::string, std::string>* gProps;

// Caller holds gPropLock.
static std::map<std::string, std::string>& props() {
  if (gProps != nullptr) return *gProps;
  gProps = new std::map<std::string, std::string>();
  const char* root = getenv("ANDROID_ROOT");
  std::string path = std::string(root ? root : "/system") + "/build.prop";
  FILE* f = fopen(path.c_str(), "r");
  if (f == nullptr) {
    fprintf(stderr, "q20 props: cannot open %s, every property reads empty\n", path.c_str());
    return *gProps;
  }
  char line[512];
  while (fgets(line, sizeof(line), f) != nullptr) {
    size_t n = strcspn(line, "\r\n");
    line[n] = '\0';
    char* eq = strchr(line, '=');
    if (line[0] == '#' || eq == nullptr) continue;
    *eq = '\0';
    (*gProps)[line] = eq + 1;
  }
  fclose(f);
  return *gProps;
}

int property_get(const char* key, char* value, const char* default_value) {
  pthread_mutex_lock(&gPropLock);
  std::map<std::string, std::string>& p = props();
  std::map<std::string, std::string>::const_iterator it = p.find(key);
  const char* v = (it != p.end() && !it->second.empty()) ? it->second.c_str() : default_value;
  int len = 0;
  if (v != nullptr) {
    len = strlen(v);
    if (len > PROPERTY_VALUE_MAX - 1) len = PROPERTY_VALUE_MAX - 1;
    memcpy(value, v, len);
  }
  value[len] = '\0';
  pthread_mutex_unlock(&gPropLock);
  return len;
}

int property_set(const char* key, const char* value) {
  pthread_mutex_lock(&gPropLock);
  props()[key] = value ? value : "";
  pthread_mutex_unlock(&gPropLock);
  return 0;
}

namespace android {
// Trace.<clinit> registers here; nothing ever reports a change (see above).
void add_sysprop_change_callback(sysprop_change_callback, int) {}
}  // namespace android

static jint Binder_getCallingPid(JNIEnv*, jclass) { return getpid(); }
static jint Binder_getCallingUid(JNIEnv*, jclass) { return getuid(); }

// Deterministic: Looper.loop compares the identity before and after each message.
static jlong Binder_clearCallingIdentity(JNIEnv*, jclass) {
  return (static_cast<jlong>(getuid()) << 32) | static_cast<uint32_t>(getpid());
}
static void Binder_restoreCallingIdentity(JNIEnv*, jclass, jlong) {}
static void Binder_flushPendingCommands(JNIEnv*, jclass) {}

// ponytail: one policy for the whole process, not per thread.
static int gStrictModePolicy;
static void Binder_setThreadStrictModePolicy(JNIEnv*, jclass, jint policy) { gStrictModePolicy = policy; }
static jint Binder_getThreadStrictModePolicy(JNIEnv*, jclass) { return gStrictModePolicy; }

// Local Binder objects (every IFoo.Stub) need no native state without a driver.
static void Binder_init(JNIEnv*, jobject) {}
static void Binder_destroy(JNIEnv*, jobject) {}

static JNINativeMethod gBinderMethods[] = {
  { "getCallingPid", "()I", reinterpret_cast<void*>(Binder_getCallingPid) },
  { "getCallingUid", "()I", reinterpret_cast<void*>(Binder_getCallingUid) },
  { "clearCallingIdentity", "()J", reinterpret_cast<void*>(Binder_clearCallingIdentity) },
  { "restoreCallingIdentity", "(J)V", reinterpret_cast<void*>(Binder_restoreCallingIdentity) },
  { "flushPendingCommands", "()V", reinterpret_cast<void*>(Binder_flushPendingCommands) },
  { "setThreadStrictModePolicy", "(I)V", reinterpret_cast<void*>(Binder_setThreadStrictModePolicy) },
  { "getThreadStrictModePolicy", "()I", reinterpret_cast<void*>(Binder_getThreadStrictModePolicy) },
  { "init", "()V", reinterpret_cast<void*>(Binder_init) },
  { "destroy", "()V", reinterpret_cast<void*>(Binder_destroy) },
};

static jlong Trace_nativeGetEnabledTags(JNIEnv*, jclass) { return 0; }

static JNINativeMethod gTraceMethods[] = {
  { "nativeGetEnabledTags", "()J", reinterpret_cast<void*>(Trace_nativeGetEnabledTags) },
};

void register_qnx_android_os(JNIEnv* env) {
  jniRegisterNativeMethods(env, "android/os/Binder", gBinderMethods, NELEM(gBinderMethods));
  jniRegisterNativeMethods(env, "android/os/Trace", gTraceMethods, NELEM(gTraceMethods));
}
