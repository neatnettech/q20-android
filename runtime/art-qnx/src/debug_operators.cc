/*
 * QNX port: debug-only stream operators.
 *
 * AOSP 6.0.1 declares these operators in headers but defines them nowhere
 * (release builds compile the LOG/DCHECK call sites out with NDEBUG, so the
 * references never appear). Our port builds with assertions and verbose
 * logging on, so provide minimal definitions that print the enum values.
 */

#include <ostream>

#include "arch/instruction_set.h"
#include "base/mutex.h"
#include "base/unix_file/fd_file.h"
#include "debugger.h"
#include "dex_file.h"
#include "dex_instruction.h"
#include "gc/allocator/rosalloc.h"
#include "gc/allocator_type.h"
#include "gc/collector/gc_type.h"
#include "gc/collector_type.h"
#include "gc/heap.h"
#include "gc/space/space.h"
#include "gc_root.h"
#include "image.h"
#include "../compiler/image_writer.h"
#include "../compiler/dex/compiler_enums.h"
#include "../compiler/dex/mir_field_info.h"
#include "../compiler/dex/global_value_numbering.h"
#include "../compiler/dex/pass_me.h"
#include "../compiler/dex/quick/resource_mask.h"
#include "../compiler/dex/quick/dex_file_method_inliner.h"
#include "../compiler/dex/quick/arm/arm_lir.h"
#include "../compiler/driver/compiler_driver.h"
#include "../compiler/driver/compiler_options.h"
#include "../compiler/utils/arm/assembler_arm.h"
#include "indirect_reference_table.h"
#include "instrumentation.h"
#include "invoke_type.h"
#include "jdwp/jdwp.h"
#include "jdwp/jdwp_constants.h"
#include "lock_word.h"
#include "mirror/class.h"
#include "oat.h"
#include "profiler_options.h"
#include "stack.h"
#include "thread.h"
#include "thread_state.h"
#include "verifier/method_verifier.h"

namespace art {

std::ostream& operator<<(std::ostream& os, const LockLevel& rhs) {
  return os << "LockLevel[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const ThreadState& rhs) {
  return os << "ThreadState[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const InvokeType& rhs) {
  return os << "InvokeType[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const IndirectRefKind& rhs) {
  return os << "IndirectRefKind[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const Instruction::Format& rhs) {
  return os << "Format[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const ProfileDataType& rhs) {
  return os << "ProfileDataType[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const InstructionSet& rhs) {
  return os << "InstructionSet[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const ImageHeader::ImageMethod& rhs) {
  return os << "ImageMethod[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const ImageHeader::ImageSections& rhs) {
  return os << "ImageSections[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const RootType& rhs) {
  return os << "RootType[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const DeoptimizationRequest::Kind& rhs) {
  return os << "DeoptKind[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const OatClassType& rhs) {
  return os << "OatClassType[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const VRegKind& rhs) {
  return os << "VRegKind[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const LockWord::LockState& rhs) {
  return os << "LockState[" << static_cast<uint32_t>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const ImageWriter::Bin& rhs) {
  return os << "Bin[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const BBType& rhs) {
  return os << "BBType[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const BlockListType& rhs) {
  return os << "BlockListType[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const SelectInstructionKind& rhs) {
  return os << "SelectInstructionKind[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const DexMemAccessType& rhs) {
  return os << "DexMemAccessType[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const RegLocationType& rhs) {
  return os << "RegLocationType[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const OpSize& rhs) {
  return os << "OpSize[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const DataFlowAnalysisMode& rhs) {
  return os << "DataFlowAnalysisMode[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const GlobalValueNumbering::Mode& rhs) {
  return os << "GVNMode[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const ResourceMask::ResourceBit& rhs) {
  return os << "ResourceBit[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const InlineMethodOpcode& rhs) {
  return os << "InlineMethodOpcode[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const ArmOpcode& rhs) {
  return os << "ArmOpcode[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const ArmEncodingKind& rhs) {
  return os << "ArmEncodingKind[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const OpKind& rhs) {
  return os << "OpKind[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const ConditionCode& rhs) {
  return os << "ConditionCode[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const DividePattern& rhs) {
  return os << "DividePattern[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const DexToDexCompilationLevel& rhs) {
  return os << "DexToDexCompilationLevel[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const RegisterClass& rhs) {
  return os << "RegisterClass[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const MemBarrierKind& rhs) {
  return os << "MemBarrierKind[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const CompilerOptions::CompilerFilter& rhs) {
  return os << "CompilerFilter[" << static_cast<int>(rhs) << "]";
}

namespace arm {

std::ostream& operator<<(std::ostream& os, const Opcode& rhs) {
  return os << "Opcode[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const Shift& rhs) {
  return os << "Shift[" << static_cast<int>(rhs) << "]";
}

}  // namespace arm

std::ostream& operator<<(std::ostream& os, const StackedShadowFrameType& rhs) {
  return os << "StackedShadowFrameType[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os,
                         const EncodedStaticFieldValueIterator::ValueType& rhs) {
  return os << "StaticFieldValueType[" << static_cast<int>(rhs) << "]";
}

namespace gc {

std::ostream& operator<<(std::ostream& os, const AllocatorType& rhs) {
  return os << "AllocatorType[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const CollectorType& rhs) {
  return os << "CollectorType[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const ProcessState& rhs) {
  return os << "ProcessState[" << static_cast<int>(rhs) << "]";
}

namespace allocator {

std::ostream& operator<<(std::ostream& os, const RosAlloc::PageMapKind& rhs) {
  return os << "PageMapKind[" << static_cast<int>(rhs) << "]";
}

}  // namespace allocator

namespace collector {

std::ostream& operator<<(std::ostream& os, const GcType& rhs) {
  return os << "GcType[" << static_cast<int>(rhs) << "]";
}

}  // namespace collector

namespace space {

std::ostream& operator<<(std::ostream& os, const SpaceType& rhs) {
  return os << "SpaceType[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const GcRetentionPolicy& rhs) {
  return os << "GcRetentionPolicy[" << static_cast<int>(rhs) << "]";
}

}  // namespace space
}  // namespace gc

namespace instrumentation {

std::ostream& operator<<(std::ostream& os, const Instrumentation::InstrumentationEvent& rhs) {
  return os << "InstrumentationEvent[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const Instrumentation::InstrumentationLevel& rhs) {
  return os << "InstrumentationLevel[" << static_cast<int>(rhs) << "]";
}

}  // namespace instrumentation

namespace verifier {

std::ostream& operator<<(std::ostream& os, const MethodType& rhs) {
  return os << "MethodType[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const MethodVerifier::FailureKind& rhs) {
  return os << "FailureKind[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const VerifyError& rhs) {
  return os << "VerifyError[" << static_cast<int>(rhs) << "]";
}

}  // namespace verifier


namespace JDWP {

std::ostream& operator<<(std::ostream& os, const JdwpTransportType& rhs) {
  return os << "JdwpTransportType[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const JdwpTag& rhs) {
  return os << "JdwpTag[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const JdwpError& rhs) {
  return os << "JdwpError[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const JdwpStepDepth& rhs) {
  return os << "JdwpStepDepth[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const JdwpStepSize& rhs) {
  return os << "JdwpStepSize[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const JdwpEventKind& rhs) {
  return os << "JdwpEventKind[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const JdwpModKind& rhs) {
  return os << "JdwpModKind[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const JdwpSuspendPolicy& rhs) {
  return os << "JdwpSuspendPolicy[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const JdwpSuspendStatus& rhs) {
  return os << "JdwpSuspendStatus[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const JdwpThreadStatus& rhs) {
  return os << "JdwpThreadStatus[" << static_cast<int>(rhs) << "]";
}

std::ostream& operator<<(std::ostream& os, const JdwpTypeTag& rhs) {
  return os << "JdwpTypeTag[" << static_cast<int>(rhs) << "]";
}

}  // namespace JDWP

namespace mirror {

std::ostream& operator<<(std::ostream& os, const Class::Status& rhs) {
  return os << "ClassStatus[" << static_cast<int>(rhs) << "]";
}

}  // namespace mirror
}  // namespace art

namespace unix_file {

std::ostream& operator<<(std::ostream& os, const FdFile::GuardState& rhs) {
  return os << "GuardState[" << static_cast<int>(rhs) << "]";
}

}  // namespace unix_file