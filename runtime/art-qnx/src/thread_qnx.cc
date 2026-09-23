/*
 * QNX thread port for ART 6.0.1.
 *
 * SetUpAlternateSignalStack/TearDownAlternateSignalStack are no-ops: QNX has
 * no sigaltstack (verified on-device, see runtime/qnx-shims/stackguard-probe.c)
 * and ART on QNX runs with implicit SO checks disabled (runtime.cc patch),
 * so the alternate signal stack serves no purpose. Mirrors thread_android.cc
 * where bionic does the work.
 */

#include "thread.h"
#include "utils.h"

namespace art {

void Thread::SetNativePriority(int) {
  // Do nothing.
}

int Thread::GetNativePriority() {
  return kNormThreadPriority;
}

void Thread::SetUpAlternateSignalStack() {
  // QNX has no sigaltstack.
}

void Thread::TearDownAlternateSignalStack() {
  // QNX has no sigaltstack.
}

}  // namespace art
