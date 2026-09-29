# Platform research

Status: current phase (M1 to M2). Exit criterion: one preferred platform
plus one fallback, each justified against the security requirements. No PCB
work before this is locked.

## Evaluation criteria

Security (hard):

* CPU architecture (ARM64, ARMv9 preferred)
* MTE
* TEE
* secure boot and AVB
* StrongBox class secure element support
* hardware key attestation
* rollback protection
* IOMMU
* virtualization (pKVM)

Integration:

* GPU, display, camera interfaces
* USB, PCIe, UFS, RAM
* modem isolation
* Linux and Android BSP
* kernel source availability
* firmware availability
* documentation and licensing (independent developer access)
* SOM availability
* lifecycle, cost

## Candidates

Qualcomm gets priority because of the Android and security ecosystem.

| Platform | Notes | Security feature evidence |
| --- | --- | --- |
| QCM6490 | 8 core Kryo 670, LPDDR5, UFS 3.1, PCIe Gen3, 5G, long lifecycle | older ARM architecture; MTE and StrongBox class not assumed |
| QCS6490 | same family as QCM6490 | same caveats |
| QCS8550 | 4 nm, 8 core Kryo up to 3.2 GHz, LPDDR5X, 2x MIPI DSI, DP, Wi-Fi 7 companion, BT 5.3, 10 year lifecycle, Android/Linux/Ubuntu, Open-Q 8550CS SOM | lead candidate; boot chain accessibility under investigation |
| newer Dragonwing | tbd | tbd |

Others:

* MediaTek: recent dimensity lines carry MTE and StrongBox class
  attestation, but BSP and firmware access for independents unclear
* Rockchip: good Linux BSP, weak security feature set
* NXP: strong secure element ecosystem, phone class SoCs not competitive
* Samsung: Exynos has strong security, poor third party support

## Open questions (blocking selection)

1. QCS8550 boot and security chain: which stages are documented and
   accessible to an independent developer, which sit behind Qualcomm NDA
   (see ../security/BOOT_CHAIN.md)
2. MTE and pKVM support status on QCS8550 silicon
3. Android BSP licensing terms
4. Secure element part and provisioning story (ADR-0003)
5. SOM price and availability (Open-Q 8550CS)
6. Compare 2 to 3 contemporary alternatives against the same criteria

## Findings so far

* GrapheneOS hardware requirements include MTE or equivalent, isolated
  peripherals, StrongBox secure element, hardware key attestation,
  rollback protected verified boot, and A/B firmware and OS updates
* GrapheneOS device support requires a device specific kernel, driver
  libraries, firmware, SELinux policy, verified boot, attestation, and
  device specific hardware integration; even USB-C hardware control needs
  device specific driver work
* Qualcomm lists QCS8550 as an active Dragonwing platform with Android,
  Linux, and Ubuntu support and a 10 year lifecycle; QCS8550 development
  systems with 16 GB LPDDR5X and UFS exist

## References

* https://discuss.grapheneos.org/d/10039-including-more-device-compatibility/1
* https://docs.qualcomm.com/doc/87-28733-1/87-28733-1_REV_E_QUALCOMM_QCS6490_QCM6490_Processors_Product_Brief.pdf
* https://www.qualcomm.com/internet-of-things/applications/commercial-infrastructure
* https://www.qualcomm.com/internet-of-things/hardware
* https://grapheneos.org/build
