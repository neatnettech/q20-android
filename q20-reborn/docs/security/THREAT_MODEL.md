# Threat model

## Attackers

```text
Physical attacker
   │
   ├─ stolen device
   ├─ unlocked device
   ├─ extracted storage
   ├─ debug port
   ├─ malicious USB
   └─ motherboard access

Remote attacker
   │
   ├─ Android exploit
   ├─ browser exploit
   ├─ modem
   ├─ WiFi
   └─ Bluetooth
```

## Boundary behavior

What happens when each boundary is compromised. To be filled during phase
03; the table below is the working skeleton.

| Attack | Boundary | Expected behavior | Status |
| --- | --- | --- | --- |
| stolen device, locked | disk encryption + StrongBox | data unrecoverable without user secret | tbd |
| stolen device, unlocked | OS + user education | device wipe on relock | tbd |
| extracted storage | UFS encryption keys in secure element | ciphertext only | tbd |
| debug port | no production debug access | nothing exposed | policy |
| malicious USB | USB isolation + host restrictions | no data path by default | tbd |
| motherboard access | anti tamper + key hierarchy | keys bound to device | tbd |
| Android/browser exploit | sandbox + SELinux + MTE | contained to app | tbd |
| modem/WiFi/BT compromise | hardware isolation + kill switches | no DMA to main memory | tbd |

## Notes

* The modem and radio subsystems are treated as hostile from day one.
* Physical switches are the fallback when software containment fails.
