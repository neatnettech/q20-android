/*
 * QNX port: runtime signal plumbing + misc runtime stubs.
 */

#include <cstdio>
#include <cstdlib>
#include <csignal>
#include <cstring>

#include "monitor.h"
#include "runtime.h"

namespace art {

// Minimal crash handler; full register/backtrace dumps are future work.
static void HandleUnexpectedSignal(int signal_number, siginfo_t* info, void* raw_context) {
  (void)info;
  (void)raw_context;
  fprintf(stderr, "art: fatal signal %d\n", signal_number);
  fflush(stderr);
  _exit(128 + signal_number);
}

void Runtime::InitPlatformSignalHandlers() {
  // QNX has no alt stacks and no debuggerd; install a minimal handler set.
  struct sigaction action;
  memset(&action, 0, sizeof(action));
  sigemptyset(&action.sa_mask);
  action.sa_sigaction = HandleUnexpectedSignal;
  action.sa_flags = SA_SIGINFO;

  int rc = 0;
  rc += sigaction(SIGABRT, &action, nullptr);
  rc += sigaction(SIGBUS, &action, nullptr);
  rc += sigaction(SIGFPE, &action, nullptr);
  rc += sigaction(SIGILL, &action, nullptr);
  rc += sigaction(SIGPIPE, &action, nullptr);
  rc += sigaction(SIGSEGV, &action, nullptr);
  rc += sigaction(SIGTRAP, &action, nullptr);
  CHECK_EQ(rc, 0);
}

// monitor_linux.cc no-op equivalent (futex-based contention logging off).
void Monitor::LogContentionEvent(Thread* self, uint32_t wait_ms, uint32_t sample_percent,
                                 const char* owners_filename, uint32_t owners_line_number) {
  (void)self;
  (void)wait_ms;
  (void)sample_percent;
  (void)owners_filename;
  (void)owners_line_number;
}

}  // namespace art
