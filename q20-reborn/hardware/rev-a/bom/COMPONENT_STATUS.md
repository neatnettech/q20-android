# Rev A component status

| Symbol | Meaning |
| --- | --- |
| 🟢 | LOCKED |
| 🟡 | UNDER EVALUATION |
| 🔴 | NOT SELECTED |
| ⚫ | REJECTED |

A component becomes 🟢 only after all of: datasheet reviewed, electrical
requirements reviewed, footprint verified, availability checked, lifecycle
checked, software support checked, architecture approved.

| Block | Candidate | Status | Blocking item |
| --- | --- | --- | --- |
| SOM | QCS8550 SOM (Open-Q 8550CS class, exact SKU TBD) | 🟡 | SOM hardware documentation, see ADR-0002 |
| Secure element | NXP SE050 family (exact variant TBD) | 🟡 | Android integration path, see ADR-0003 |
| Secure element | NXP SN100 | ⚫ | not an appropriate generic Android StrongBox implementation |
| Modem | Quectel `RM500Q-GL` | 🟡 | hardware design guide, power architecture |
| Modem power isolation | TI `TPS22965` | 🟡 | peak current, drop, leakage, control domain review |
| Secure element LDO | TBD | 🔴 | depends on SE variant |
| Charger and power path | TBD | 🔴 | power tree |
| USB C PD controller | TBD | 🔴 | power tree |
| USB C protection | TBD | 🔴 | power tree |
| Peripheral regulators (PER_3V3, PER_1V8) | TBD | 🔴 | load list |
| Battery | TBD | 🔴 | mechanical, power tree |
| Display | TBD | 🔴 | SOM display interface |
| Keyboard | Q20 keyboard (interface TBD) | 🔴 | peripheral prototyping (stage 05) |
| Trackpad | Q20 style trackpad (part TBD) | 🔴 | peripheral prototyping (stage 05) |
| Audio codec and amplifier | TBD | 🔴 | SOM audio interface |
| Cameras | TBD | 🔴 | SOM camera interface |
| WiFi/Bluetooth | TBD (SOM integrated or external) | 🔴 | SOM documentation |
| Debug (UART bridge, connectors) | TBD | 🔴 | SOM debug interface |
