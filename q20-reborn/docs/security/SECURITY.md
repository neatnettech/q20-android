# Security architecture

## Goals

A device whose security properties we can verify ourselves, not a device
that inherits marketing claims. Hard requirements are in REQUIREMENTS.md.

## Bootloader unlock policy

Unlock is an intentional security state transition, never permanently
open.

## Debug access

Development header (UART, JTAG/SWD, SPI, I2C, GPIO) on development boards,
physically inaccessible in the production enclosure, with a documented
production process for disabling and removing debug access.

## Self attack (phase 10)

Once Rev B works, attack the phone ourselves and document every result:

* bootloader attacks
* downgrade attacks
* storage extraction
* malicious USB
* UART access
* JTAG access
* modem compromise
* Wi-Fi compromise
* Bluetooth compromise
* DMA attacks
* physical switch bypass
* firmware replacement

## Related

* BOOT_CHAIN.md: which platform stages we can actually control
* THREAT_MODEL.md: attacker trees and boundary behavior
* RADIO_ISOLATION.md: hardware kill switches
