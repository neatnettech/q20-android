/*
 * QNX port: liblog stubs (stderr).
 *
 * ponytail: real liblog routes to slog2 via the Q20 runtime's own liblog.so;
 * for the first milestones fprintf to stderr is enough. Replace with slog2
 * integration when on-device logging matters.
 */

#include <cstdarg>
#include <cstdio>

extern "C" {

int __android_log_print(int prio, const char* tag, const char* fmt, ...) {
  (void)prio;
  fprintf(stderr, "%s: ", tag != nullptr ? tag : "?");
  va_list ap;
  va_start(ap, fmt);
  vfprintf(stderr, fmt, ap);
  va_end(ap);
  fprintf(stderr, "\n");
  return 0;
}

int __android_log_vprint(int prio, const char* tag, const char* fmt, va_list ap) {
  (void)prio;
  fprintf(stderr, "%s: ", tag != nullptr ? tag : "?");
  vfprintf(stderr, fmt, ap);
  fprintf(stderr, "\n");
  return 0;
}

int __android_log_buf_print(int bufID, int prio, const char* tag, const char* fmt, ...) {
  (void)bufID;
  (void)prio;
  fprintf(stderr, "%s: ", tag != nullptr ? tag : "?");
  va_list ap;
  va_start(ap, fmt);
  vfprintf(stderr, fmt, ap);
  va_end(ap);
  fprintf(stderr, "\n");
  return 0;
}

int __android_log_write(int prio, const char* tag, const char* text) {
  (void)prio;
  fprintf(stderr, "%s: %s\n", tag != nullptr ? tag : "?", text);
  return 0;
}

}  // extern "C"
