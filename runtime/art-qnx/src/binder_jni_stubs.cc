/*
 * QNX binder stubs for the Parcel-only facade stage.
 *
 * Bundle and friends use android::Parcel purely as a local serialization
 * buffer; no binder IPC happens headless. These stubs provide just enough of
 * ProcessState/IPCThreadState/IBinder to link android_os_Parcel and
 * Parcel.cpp. The real driver client lands with the system-services stage,
 * backed by the resmgr binder driver from the research repo.
 */
#include <jni.h>
#include <binder/IBinder.h>
#include <binder/ProcessState.h>
#include <binder/IPCThreadState.h>
#include <utils/Vector.h>
#include <cutils/native_handle.h>
#include <android_runtime/AndroidRuntime.h>

namespace android {

// ---- android_util_Binder helpers: unused headless, return NULL ----
jobject javaObjectForIBinder(JNIEnv*, const sp<IBinder>&) { return nullptr; }
sp<IBinder> ibinderForJavaObject(JNIEnv*, jobject) { return nullptr; }
void signalExceptionForError(JNIEnv*, jobject, int, bool, int) {}
void set_dalvik_blockguard_policy(JNIEnv*, jint) {}


// ---- ProcessState: a dummy instance, no driver ----
ProcessState::ProcessState() {}
ProcessState::~ProcessState() {}
sp<ProcessState> ProcessState::self() {
  static sp<ProcessState> s(new ProcessState());
  return s;
}
sp<IBinder> ProcessState::getStrongProxyForHandle(int32_t) { return nullptr; }
wp<IBinder> ProcessState::getWeakProxyForHandle(int32_t) { return nullptr; }

// ---- IPCThreadState: policy accessors only ----
IPCThreadState* IPCThreadState::self() { return nullptr; }
void IPCThreadState::shutdown() {}
void IPCThreadState::setStrictModePolicy(int32_t) {}
int32_t IPCThreadState::getStrictModePolicy() const { return 0; }
int32_t IPCThreadState::getLastTransactionBinderFlags() const { return 0; }

}  // namespace android

// ---- libcutils pieces referenced by Parcel/ashmem paths ----
extern "C" {


int ashmem_get_size_region(int) { return 0; }
int ashmem_set_prot_region(int, int) { return 0; }

void* thread_store_get(void*) { return nullptr; }
int thread_store_set(void*, void*, void*) { return 0; }

int native_handle_delete(native_handle_t* h) { return 0; }

native_handle_t* native_handle_create(int, int) { return nullptr; }
int native_handle_close(const native_handle_t*) { return 0; }



}
