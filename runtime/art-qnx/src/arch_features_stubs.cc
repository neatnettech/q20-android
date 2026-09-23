/*
 * QNX port: non-ARM instruction set feature stubs.
 *
 * The architecture dispatch (instruction_set_features.cc) references every
 * ISA's FromVariant/FromBitmap. Only ARM is built; the rest return nullptr
 * so callers fail cleanly on unsupported ISAs.
 */

#include "arch/arm64/instruction_set_features_arm64.h"
#include "arch/mips/instruction_set_features_mips.h"
#include "arch/mips64/instruction_set_features_mips64.h"
#include "arch/x86/instruction_set_features_x86.h"

namespace art {

const Arm64InstructionSetFeatures* Arm64InstructionSetFeatures::FromVariant(
    const std::string& variant, std::string* error_msg) {
  (void)variant;
  if (error_msg != nullptr)
    *error_msg = "arm64 unsupported on QNX build";
  return nullptr;
}

const Arm64InstructionSetFeatures* Arm64InstructionSetFeatures::FromBitmap(uint32_t bitmap) {
  (void)bitmap;
  return nullptr;
}

const MipsInstructionSetFeatures* MipsInstructionSetFeatures::FromVariant(
    const std::string& variant, std::string* error_msg) {
  (void)variant;
  if (error_msg != nullptr)
    *error_msg = "mips unsupported on QNX build";
  return nullptr;
}

const MipsInstructionSetFeatures* MipsInstructionSetFeatures::FromBitmap(uint32_t bitmap) {
  (void)bitmap;
  return nullptr;
}

const Mips64InstructionSetFeatures* Mips64InstructionSetFeatures::FromVariant(
    const std::string& variant, std::string* error_msg) {
  (void)variant;
  if (error_msg != nullptr)
    *error_msg = "mips64 unsupported on QNX build";
  return nullptr;
}

const Mips64InstructionSetFeatures* Mips64InstructionSetFeatures::FromBitmap(uint32_t bitmap) {
  (void)bitmap;
  return nullptr;
}

const X86InstructionSetFeatures* X86InstructionSetFeatures::FromVariant(
    const std::string& variant, std::string* error_msg, bool x86_64) {
  (void)variant;
  (void)x86_64;
  if (error_msg != nullptr)
    *error_msg = "x86 unsupported on QNX build";
  return nullptr;
}

const X86InstructionSetFeatures* X86InstructionSetFeatures::FromBitmap(uint32_t bitmap,
                                                                       bool x86_64) {
  (void)bitmap;
  (void)x86_64;
  return nullptr;
}

}  // namespace art
