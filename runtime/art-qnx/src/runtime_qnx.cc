/*
 * QNX port: runtime signal plumbing + misc runtime stubs.
 */

#include <cstdio>
#include <cstdlib>
#include <csignal>
#include <cstring>
#include <dlfcn.h>

#include "monitor.h"
#include "runtime.h"

extern "C" char _btext[];

namespace art {

// Minimal crash handler; full register/backtrace dumps are future work.
static void HandleUnexpectedSignal(int signal_number, siginfo_t* info, void* raw_context) {
  struct sigcontext sc;
  qnx_fill_sigcontext(&sc, raw_context);
  fprintf(stderr, "art: fatal signal %d fault=%p code=%d pc=%p lr=%p\n", signal_number,
          info != nullptr ? info->si_addr : nullptr,
          info != nullptr ? info->si_code : 0,
          reinterpret_cast<void*>(sc.arm_pc),
          reinterpret_cast<void*>(sc.arm_lr));
  fprintf(stderr, "art: anchor btext=%p\n", _btext);
  fprintf(stderr, "art: regs r0=%08lx r1=%08lx r2=%08lx r3=%08lx r4=%08lx r5=%08lx r6=%08lx r7=%08lx sp=%08lx\n",
          sc.arm_r0, sc.arm_r1, sc.arm_r2, sc.arm_r3, sc.arm_r4, sc.arm_r5,
          sc.arm_r6, sc.arm_r7, sc.arm_sp);
  {
    FILE* maps = fopen("/proc/self/mappings", "re");
    if (maps != nullptr) {
      char line[512];
      char name[256];
      unsigned long lo = 0, hi = 0;
      char cur_name[256] = "";
      int first = 1;
      auto flush = [&]() {
        if (cur_name[0] != '\0' && (strstr(cur_name, "libart") || strstr(cur_name, "dex2oat")
            || strstr(cur_name, "boot.oat") || strstr(cur_name, "libc.so")
            || strstr(cur_name, "libstdc++") || strstr(cur_name, "libgcc"))) {
          fprintf(stderr, "art: map %08lx-%08lx %s\n", lo, hi, cur_name);
        }
      };
      while (fgets(line, sizeof(line), maps) != nullptr) {
        unsigned long v;
        char nm[256];
        if (first) { first = 0; continue; }
        if (sscanf(line, "%lx,", &v) != 1) continue;
        char* comma = strrchr(line, ',');
        const char* nm_start = comma != nullptr ? comma + 1 : "";
        // strip trailing newline
        strncpy(nm, nm_start, sizeof(nm) - 1);
        nm[sizeof(nm) - 1] = '\0';
        char* nl = strchr(nm, '\n');
        if (nl != nullptr) *nl = '\0';
        if (strcmp(nm, cur_name) != 0) {
          flush();
          strcpy(cur_name, nm);
          lo = v;
        }
        hi = v + 0x1000;
      }
      flush();
      fclose(maps);
    }
  }
  const unsigned long* sp = reinterpret_cast<const unsigned long*>(sc.arm_sp);
  fprintf(stderr, "art: stack:");
  for (int i = 0; i < 48; i++) {
    fprintf(stderr, " %08lx", sp[i]);
  }
  fprintf(stderr, "\n");
  for (int i = 0; i < 16; i++) {
    Dl_info dli;
    if (dladdr(reinterpret_cast<void*>(sp[i]), &dli) != 0 && dli.dli_fname != nullptr) {
      fprintf(stderr, "art: stack[%d] %08lx = %s + %lx\n", i, sp[i], dli.dli_fname,
              sp[i] - reinterpret_cast<unsigned long>(dli.dli_fbase));
    }
  }
  unsigned long lo = sc.arm_sp;
  unsigned long hi = sc.arm_sp + 0x3000;
  fprintf(stderr, "art: scan [%08lx-%08lx]:", lo, hi);
  for (unsigned long a = lo; a < hi; a += 4) {
    unsigned long v = *reinterpret_cast<unsigned long*>(a);
    if ((v >= 0x10000000 && v < 0x20000000) || (v >= 0x70000000 && v < 0x80000000)) {
      fprintf(stderr, " %08lx", v);
    }
  }
  fprintf(stderr, "\n");
  unsigned long fp = sc.arm_r7;
  for (int depth = 0; depth < 24 && fp != 0 && fp >= sc.arm_sp && fp < sc.arm_sp + 0x10000; depth++) {
    unsigned long saved_r7 = *reinterpret_cast<unsigned long*>(fp);
    unsigned long saved_lr = *reinterpret_cast<unsigned long*>(fp + 4);
    Dl_info dli;
    if (dladdr(reinterpret_cast<void*>(saved_lr), &dli) != 0 && dli.dli_fname != nullptr) {
      fprintf(stderr, "art: frame %d fp=%08lx lr=%08lx %s + %lx\n", depth, fp, saved_lr,
              dli.dli_fname, saved_lr - reinterpret_cast<unsigned long>(dli.dli_fbase));
    } else {
      fprintf(stderr, "art: frame %d fp=%08lx lr=%08lx\n", depth, fp, saved_lr);
    }
    if (saved_r7 <= fp) break;
    fp = saved_r7;
  }
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
