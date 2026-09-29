# Q20 Reborn: requirements

## Functional

* ARM64
* Android / GrapheneOS
* cellular
* Wi-Fi
* Bluetooth
* GNSS
* NFC
* USB-C
* 3.5 mm audio
* camera
* speaker
* microphone
* physical keyboard
* trackpad
* touchscreen
* replaceable battery

## Security

* secure boot
* verified boot
* rollback protection
* hardware backed keystore
* StrongBox class secure element
* hardware key attestation
* IOMMU
* isolated peripherals
* radio hardware isolation
* USB isolation
* user configurable root of trust
* A/B firmware
* A/B OS

## Engineering

* open documentation wherever possible
* reproducible firmware
* reproducible OS builds
* serviceable hardware
* no unnecessary cloud dependency
* USB debugging physically inaccessible in production

## Hardware security requirements

| Subsystem | Requirement |
| --- | --- |
| CPU | ARM64, ARMv9 preferred |
| MTE | required if supported by platform |
| Memory | LPDDR5X |
| Storage | UFS 3.1 / 4.x |
| Verified boot | hardware root + AVB |
| Rollback | hardware protected |
| Secure element | StrongBox class |
| Attestation | hardware key attestation |
| TEE | required |
| IOMMU | required |
| pKVM / virtualization | required or desirable |
| Radio isolation | hardware enforced |
| USB isolation | hardware enforced |
| Firmware A/B | required |
| OS A/B | required |
| Modem | isolated subsystem |
| Wi-Fi/BT | isolated subsystem |
| Camera | MIPI CSI |
| Display | MIPI DSI |
| Keyboard | dedicated controller |
| Trackpad | dedicated controller |
| Battery | replaceable |
| Enclosure | CNC |

## Envelope

Approximately 145 x 76 x 14 to 16 mm. Extra thickness buys battery,
thermals, shielding, antennas, switches, and serviceability.
