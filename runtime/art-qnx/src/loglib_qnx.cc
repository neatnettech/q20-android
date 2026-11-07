/*
 * QNX liblog subset for libjavacore and the framework JNI files. Android's
 * liblog writes to logd; here everything goes to stderr and a plain file
 * under $ANDROID_DATA so app logs survive without a log daemon.
 */
#include <android/log.h>
#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>

static void qnx_log_write(int prio, const char* tag, const char* msg) {
  FILE* f = stderr;
  fprintf(f, "ALOG %d %s: %s\n", prio, tag ? tag : "-", msg);
  const char* data = getenv("ANDROID_DATA");
  if (data != NULL) {
    char path[512];
    snprintf(path, sizeof(path), "%s/qnx-android-log.txt", data);
    FILE* lf = fopen(path, "a");
    if (lf != NULL) {
      fprintf(lf, "ALOG %d %s: %s\n", prio, tag ? tag : "-", msg);
      fclose(lf);
    }
  }
}

extern "C" int __android_log_buf_write(int bufID, int prio, const char* tag,
                                       const char* msg) {
  (void)bufID;
  qnx_log_write(prio, tag, msg);
  return 0;
}

extern "C" int __android_log_write(int prio, const char* tag, const char* msg) {
  qnx_log_write(prio, tag, msg);
  return 0;
}

extern "C" int __android_log_print(int prio, const char* tag, const char* fmt, ...) {
  char buf[512];
  va_list ap;
  va_start(ap, fmt);
  vsnprintf(buf, sizeof(buf), fmt, ap);
  va_end(ap);
  qnx_log_write(prio, tag, buf);
  return 0;
}

extern "C" int __android_log_vprint(int prio, const char* tag, const char* fmt, va_list ap) {
  char buf[512];
  vsnprintf(buf, sizeof(buf), fmt, ap);
  qnx_log_write(prio, tag, buf);
  return 0;
}

extern "C" int __android_log_is_loggable(int prio, const char* tag,
                                         int default_prio) {
  (void)tag;
  return prio >= default_prio ? 1 : 0;
}

// EventLog (android_util_EventLog.cpp): the binary event buffer. No event logd
// on QNX, so writes discard and the reader (EventLog.readEvents) sees nothing.
// Loose arg types: C symbols don't mangle, and these are all int/pointer sized.
#include <stdint.h>
extern "C" int __android_log_bwrite(int32_t tag, const void* payload, size_t len) {
  (void) tag; (void) payload; return (int) len;
}
extern "C" int __android_log_btwrite(int32_t tag, char type, const void* payload, size_t len) {
  (void) tag; (void) type; (void) payload; return (int) len;
}
extern "C" void* android_logger_list_open(int id, int mode, unsigned int tail, int pid) {
  (void) id; (void) mode; (void) tail; (void) pid; return 0;
}
extern "C" int android_logger_list_read(void* list, void* msg) {
  (void) list; (void) msg; return -1;  // nothing to read
}
extern "C" void android_logger_list_free(void* list) { (void) list; }
