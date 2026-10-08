# Rev A component selection

Status board: [../bom/COMPONENT_STATUS.md](../bom/COMPONENT_STATUS.md).
Every physical component that reaches the PCB needs all fields below
verified. Unknown values are `TBD`; never estimate silently.

Required per component: manufacturer, MPN, datasheet, electrical
characteristics, pinout, package, footprint, thermal requirements,
availability, lifecycle, software support.

## SOM (U301)

| Field | Value |
| --- | --- |
| Manufacturer | TBD |
| MPN | TBD (Open-Q 8550CS class, ADR-0002) |
| Datasheet / hardware guide | TBD |
| Input voltage range | TBD |
| Max current / startup current | TBD |
| Power sequencing, enable, shutdown, power good | TBD |
| Exposed peripheral rails | TBD |
| IO voltage levels | TBD |
| Board to board connector MPN | TBD |
| Thermal requirements | TBD |
| Status | 🟡 |

SOM power requirements come from the SOM manufacturer documentation only,
never derived from the QCS8550 SoC datasheet.

## Secure element (U201)

| Field | Value |
| --- | --- |
| Manufacturer | NXP |
| MPN | SE050 family, exact variant TBD |
| Interface | I²C (bus parameters TBD, see INTERCONNECTS.md) |
| Supply | SE_3V3 via dedicated LDO (regulator TBD) |
| Reset, interrupt, tamper signals | TBD |
| Android integration path | TBD (see SECURITY_ARCHITECTURE.md) |
| Status | 🟡 |

Schematic name is `SECURE_ELEMENT`, not `STRONGBOX`, until the Android
StrongBox implementation is proven. SN100 is ⚫ rejected.

## Modem (U401)

| Field | Value |
| --- | --- |
| Manufacturer | Quectel |
| MPN | `RM500Q-GL` |
| Form factor / connector | TBD |
| Main supply range | TBD (expected roughly 3.7 V class, confirm from hardware design guide) |
| Peak current | TBD |
| Host interface | TBD |
| SIM interface | TBD |
| Antenna requirements | TBD |
| Status | 🟡, do not lock into the PCB yet |

## Modem power isolation switch

| Field | Value |
| --- | --- |
| Manufacturer | Texas Instruments |
| MPN | `TPS22965` (exact orderable suffix TBD) |
| Pins | 1, 2 VIN; 3 ON; 4 VBIAS; 5 GND; 6 CT; 7, 8 VOUT; 9 exposed pad |
| Power good pin | none |
| Max continuous / peak current vs modem peak | TBD |
| Voltage drop at modem peak | TBD |
| Thermal dissipation | TBD |
| Reverse current behavior | TBD |
| Shutdown leakage | TBD |
| Control domain voltage | TBD |
| Status | 🟡 |

Selection criteria: voltage range, peak current, voltage drop, thermal
dissipation, reverse current, shutdown leakage, fault behavior, switching
speed, control domain voltage. Use the manufacturer symbol, not the concept
symbol. Exposed pad per TI datasheet.

## Power: charger, power path, USB C PD, regulators

| Function | MPN | Status |
| --- | --- | --- |
| USB C protection | TBD | 🔴 |
| USB C PD controller | TBD | 🔴 |
| Charger / power path | TBD | 🔴 |
| PER_3V3 regulator | TBD | 🔴 |
| PER_1V8 regulator | TBD | 🔴 |
| SE_3V3 LDO | TBD | 🔴 |
| Battery pack | TBD | 🔴 |

## Peripherals

| Function | MPN | Interface | Status |
| --- | --- | --- | --- |
| Display | TBD | TBD | 🔴 |
| Keyboard | Q20 keyboard | TBD | 🔴 |
| Trackpad | TBD | TBD | 🔴 |
| Audio codec | TBD | TBD | 🔴 |
| Speaker amplifier | TBD | TBD | 🔴 |
| Microphones | TBD | TBD | 🔴 |
| Cameras | TBD | TBD | 🔴 |
| WiFi/Bluetooth | TBD | TBD | 🔴 |
| Sensors | TBD | TBD | 🔴 |
| Debug UART bridge | TBD | TBD | 🔴 |
