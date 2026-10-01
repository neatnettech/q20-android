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
