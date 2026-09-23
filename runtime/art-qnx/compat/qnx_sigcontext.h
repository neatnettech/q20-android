/*
 * QNX ARM signal context translation for ART.
 *
 * ART's ARM fault handlers cast ucontext's uc_mcontext to the Linux kernel
 * `struct sigcontext` (fields arm_r0..arm_pc). QNX's mcontext_t is
 * ARM_CPU_REGISTERS { gpr[16], spsr } (+fpu). This header defines the
 * Linux-layout struct plus copy-in/copy-out helpers; ART code uses a local
 * struct and the helpers instead of the raw cast.
 */
#ifndef ART_QNX_SIGCONTEXT_H
#define ART_QNX_SIGCONTEXT_H

#include <arm/context.h>
#include <string.h>
#include <ucontext.h>

struct sigcontext {
  unsigned long trap_no;
  unsigned long error_code;
  unsigned long oldmask;
  unsigned long arm_r0;
  unsigned long arm_r1;
  unsigned long arm_r2;
  unsigned long arm_r3;
  unsigned long arm_r4;
  unsigned long arm_r5;
  unsigned long arm_r6;
  unsigned long arm_r7;
  unsigned long arm_r8;
  unsigned long arm_r9;
  unsigned long arm_r10;
  unsigned long arm_fp;
  unsigned long arm_ip;
  unsigned long arm_sp;
  unsigned long arm_lr;
  unsigned long arm_pc;
  unsigned long arm_cpsr;
  unsigned long fault_address;
};

static inline void qnx_fill_sigcontext(struct sigcontext *sc, void *ucp)
{
    ucontext_t *uc = (ucontext_t *)ucp;
    memset(sc, 0, sizeof(*sc));
    sc->arm_r0  = uc->uc_mcontext.cpu.gpr[ARM_REG_R0];
    sc->arm_r1  = uc->uc_mcontext.cpu.gpr[ARM_REG_R1];
    sc->arm_r2  = uc->uc_mcontext.cpu.gpr[ARM_REG_R2];
    sc->arm_r3  = uc->uc_mcontext.cpu.gpr[ARM_REG_R3];
    sc->arm_r4  = uc->uc_mcontext.cpu.gpr[ARM_REG_R4];
    sc->arm_r5  = uc->uc_mcontext.cpu.gpr[ARM_REG_R5];
    sc->arm_r6  = uc->uc_mcontext.cpu.gpr[ARM_REG_R6];
    sc->arm_r7  = uc->uc_mcontext.cpu.gpr[ARM_REG_R7];
    sc->arm_r8  = uc->uc_mcontext.cpu.gpr[ARM_REG_R8];
    sc->arm_r9  = uc->uc_mcontext.cpu.gpr[ARM_REG_R9];
    sc->arm_r10 = uc->uc_mcontext.cpu.gpr[ARM_REG_R10];
    sc->arm_fp  = uc->uc_mcontext.cpu.gpr[ARM_REG_FP];
    sc->arm_ip  = uc->uc_mcontext.cpu.gpr[ARM_REG_IP];
    sc->arm_sp  = uc->uc_mcontext.cpu.gpr[ARM_REG_SP];
    sc->arm_lr  = uc->uc_mcontext.cpu.gpr[ARM_REG_LR];
    sc->arm_pc  = uc->uc_mcontext.cpu.gpr[ARM_REG_PC];
    sc->arm_cpsr = uc->uc_mcontext.cpu.spsr;
}

static inline void qnx_apply_sigcontext(void *ucp, const struct sigcontext *sc)
{
    ucontext_t *uc = (ucontext_t *)ucp;
    uc->uc_mcontext.cpu.gpr[ARM_REG_R0]  = sc->arm_r0;
    uc->uc_mcontext.cpu.gpr[ARM_REG_R1]  = sc->arm_r1;
    uc->uc_mcontext.cpu.gpr[ARM_REG_R2]  = sc->arm_r2;
    uc->uc_mcontext.cpu.gpr[ARM_REG_R3]  = sc->arm_r3;
    uc->uc_mcontext.cpu.gpr[ARM_REG_R4]  = sc->arm_r4;
    uc->uc_mcontext.cpu.gpr[ARM_REG_R5]  = sc->arm_r5;
    uc->uc_mcontext.cpu.gpr[ARM_REG_R6]  = sc->arm_r6;
    uc->uc_mcontext.cpu.gpr[ARM_REG_R7]  = sc->arm_r7;
    uc->uc_mcontext.cpu.gpr[ARM_REG_R8]  = sc->arm_r8;
    uc->uc_mcontext.cpu.gpr[ARM_REG_R9]  = sc->arm_r9;
    uc->uc_mcontext.cpu.gpr[ARM_REG_R10] = sc->arm_r10;
    uc->uc_mcontext.cpu.gpr[ARM_REG_FP]  = sc->arm_fp;
    uc->uc_mcontext.cpu.gpr[ARM_REG_IP]  = sc->arm_ip;
    uc->uc_mcontext.cpu.gpr[ARM_REG_SP]  = sc->arm_sp;
    uc->uc_mcontext.cpu.gpr[ARM_REG_LR]  = sc->arm_lr;
    uc->uc_mcontext.cpu.gpr[ARM_REG_PC]  = sc->arm_pc;
    uc->uc_mcontext.cpu.spsr            = sc->arm_cpsr;
}

#endif /* ART_QNX_SIGCONTEXT_H */
