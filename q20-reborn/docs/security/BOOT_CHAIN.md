# Boot chain research

## The question

Distinguish "Qualcomm says the platform has security features" from "we
can actually use those features in an independently designed device".
GrapheneOS device support requires a device specific kernel, driver
libraries, firmware, SELinux policy, verified boot, attestation, and
device specific hardware integration (USB-C hardware control included).

## QCS8550 chain to map

```text
QCS8550
   │
   ├─ Boot ROM
   ├─ PBL
   ├─ XBL
   ├─ TEE
   ├─ firmware
   ├─ secure storage
   ├─ AVB
   ├─ attestation
   ├─ StrongBox
   └─ Android BSP
          │
          ▼
      GrapheneOS
```

For each stage, record: documented for us, under NDA, or opaque.

## Open questions

1. Boot ROM: fuse layout, debug disable options, public documentation?
2. PBL/XBL: signed image requirements, where do our keys enter?
3. TEE: which TA surface is exposed, is the TEE OS source accessible?
4. Firmware: which blobs are required, signed by whom, replaceable?
5. Secure storage: key hierarchy, where does the root key live?
6. AVB: which partitions, key provisioning path for our keys?
7. Attestation: hardware key attestation chain reachable from our build?
8. StrongBox: supported secure element interface, keymaster path?
9. Android BSP: licensing, source level, kernel tree quality?
10. USB-C hardware control: exposed control interfaces for port and power?

## Exit criterion (phase 06)

We can boot our own signed OS image on the development platform and
explain: boot chain, kernel, device tree, firmware, AVB, SELinux, hardware
backed keystore, and attestation.
