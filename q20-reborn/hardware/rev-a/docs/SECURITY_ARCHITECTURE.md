# Rev A security architecture

Rev A does not claim GrapheneOS equivalent security. That claim needs the
complete hardware, boot chain, firmware, attestation and OS architecture to
be validated. Project wide security docs: [../../../docs/security/](../../../docs/security/)
(threat model, boot chain research, radio isolation).

## Terminology rule

Every security claim maps to a concrete mechanism. Marketing terms are not
requirements.

| Bad | Good |
| --- | --- |
| GrapheneOS secure | Verified Boot with rollback protection |
| StrongBox | Independent secure element (until StrongBox integration is proven) |
| secure radios | Physical modem power isolation |

## Boot chain

```text
Boot ROM
   ↓
Bootloader
   ↓
Verified Boot
   ↓
TEE / secure world
   ↓
KeyMint / Keystore
   ↓
Android OS
```

## Feature map

| Feature | Mechanism | Hardware dependency | Software dependency | Status |
| --- | --- | --- | --- | --- |
| Secure boot | TBD | QCS8550 / SOM fuse access TBD | TBD | TBD (Rev 0 inspection) |
| AVB | TBD | TBD | TBD | TBD |
| Rollback protection | TBD | TBD | TBD | TBD |
| Hardware backed keys | KeyMint in TEE | TBD | TBD | TBD |
| Attestation | TBD | TBD | TBD | TBD |
| TEE | TBD | TBD | TBD | TBD |
| StrongBox candidate | TBD | secure element TBD | KeyMint integration TBD | not claimed |
| Secure element | NXP SE050 family, I²C, SE_3V3 domain | U201 | integration TBD | 🟡 |
| pKVM | TBD | TBD | TBD | TBD (Rev 0) |
| MTE | TBD | TBD | TBD | TBD (Rev 0) |
| PAC | TBD | TBD | TBD | TBD (Rev 0) |
| BTI | TBD | TBD | TBD | TBD (Rev 0) |
| Memory isolation | TBD | TBD | TBD | TBD |
| DMA isolation / IOMMU | TBD | TBD | TBD | TBD |
| Radio isolation | physical power cut | modem isolation switch | none required | 🟡 |
| Physical power isolation | load switch on MODEM_VCC | `TPS22965` candidate | none required | 🟡 |
| Debug protection | TBD | debug connector, test pads | TBD | TBD |

## Secure element

Schematic subsystem name: `SECURE_ELEMENT`, not `STRONGBOX`.

Android StrongBox requires isolated security hardware, KeyMint integration,
secure key storage, hardware backed attestation, secure random generation,
rollback properties and appropriate Android integration. None of that is
proven for SE050 yet.

Power: PER_3V3, dedicated LDO, SE_3V3, SECURE_ELEMENT. Include input and
output capacitors, enable, reset if required, I²C pull ups, interrupt if
required, tamper signals if available.

## Hardware communication isolation

Candidate domains: MODEM, WiFi, Bluetooth, NFC, GNSS, MIC, CAMERAS.
Rev A prioritizes MODEM.

Requirements:

* Cut the actual power domain, not a software disable.
* The control signal must not be able to restore power while the
  isolation control is OFF.

## Debug as attack surface

Rev A exposes UART, USB, hardware reset and boot/recovery control, plus
JTAG/SWD if supported. Debug interfaces are part of the security
architecture. Rev C must not expose development debug by default.
