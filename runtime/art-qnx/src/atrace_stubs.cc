/*
 * QNX port: atrace stubs.
 *
 * ponytail: no systrace/ftrace on QNX. All tracing is off; the fast-path
 * inlines in cutils/trace.h check atrace_is_ready first and skip.
 */

#include <cutils/trace.h>

extern "C" {

atomic_bool atrace_is_ready = ATOMIC_VAR_INIT(0);
uint64_t atrace_enabled_tags = 0;
int atrace_marker_fd = -1;

void atrace_setup() {
}

void atrace_begin_body(const char* name) {
  (void)name;
}

void atrace_int_body(const char* name, int32_t value) {
  (void)name;
  (void)value;
}

void atrace_end_body() {
}

}
