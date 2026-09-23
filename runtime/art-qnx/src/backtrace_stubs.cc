/*
 * QNX port: libbacktrace stubs.
 *
 * ponytail: real libbacktrace needs libutils/libcutils/liblog chains; the
 * interpreter milestone does not unwind, so return an empty map. Revisit
 * when SIGQUIT dumps or crash diagnostics matter on-device.
 */

#include <backtrace/BacktraceMap.h>

BacktraceMap* BacktraceMap::Create(pid_t pid, bool uncached) {
  (void)pid;
  (void)uncached;
  return nullptr;
}

void BacktraceMap::FillIn(uintptr_t addr, backtrace_map_t* map) {
  (void)addr;
  (void)map;
}

bool BacktraceMap::Build() {
  return false;
}
