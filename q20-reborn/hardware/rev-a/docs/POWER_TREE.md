# Q20 Reborn Rev A: power tree

**Project:** Q20 Reborn
**Revision:** Rev A
**Status:** DRAFT, engineering review
**Last updated:** 2026-10-08

## 1. Purpose

Source of truth for the Rev A carrier board power architecture: rails,
rail voltages, current budgets, sources, consumers, enable signals,
sequencing, isolation, protection, decoupling, test points and schematic
ownership.

No power rail is implemented in KiCad until it is represented here.
Unknown electrical requirements are `TBD`, never estimated.

## 2. Design principles

### 2.1 No undocumented rails

Every rail has:

```text
Source
    ↓
Regulator / switch
    ↓
Rail
    ↓
Load
```

### 2.2 No invented current requirements

Current values come from, in order:

1. component datasheet
2. SOM documentation
3. measured Rev 0 hardware
4. explicitly documented engineering budget

If none exists: `TBD`.

### 2.3 Separate electrical domains

Never collapse electrically different domains into generic names such as
`+3V3`, `+5V` or `POWER`. Use explicit names such as `SE_3V3`, `PER_3V3`,
`MODEM_VCC`, `VBAT_SYS`. This keeps isolation and power ownership visible.

## 3. Architecture

```text
                           USB C
                             │
                             │ USB_VBUS
                             ▼
                    ┌──────────────────┐
                    │ USB C protection │
                    │   + PD control   │
                    └────────┬─────────┘
                             │
                             ▼
                    ┌──────────────────┐
                    │ Charger / power  │
                    │      path        │
                    └───────┬──────────┘
                            │
                ┌───────────┴───────────┐
                │                       │
                ▼                       ▼
             BATTERY                VBAT_SYS
              (VBAT)                    │
                               ┌────────┼─────────────┐
                               │        │             │
                               ▼        ▼             ▼
                          SOM POWER  HARDWARE     PERIPHERAL
                            STAGE    ISOLATOR     REGULATORS
                               │        │             │
                               ▼        ▼             ├──► PER_3V3 ──► LDO ──► SE_3V3
                            VPH_PWR  MODEM_VCC        └──► PER_1V8
                               │        │
                               ▼        ▼
                          QCS8550 SOM  5G modem
```

## 4. Canonical rails

Reserved rail names for Rev A. These names are authoritative for the
schematic, BOM and all other Rev A documents.

| Rail | Description | Status |
| --- | --- | --- |
| `USB_VBUS` | USB C input power | 🟡 |
| `VBAT` | battery cell voltage | 🟡 |
| `VBAT_SYS` | system power path rail | 🟡 |
| `VPH_PWR` | SOM primary power input | 🔴 |
| `PER_3V3` | 3.3 V peripheral rail | 🔴 |
| `PER_1V8` | 1.8 V peripheral rail | 🔴 |
| `SE_3V3` | dedicated secure element rail | 🟡 |
| `MODEM_VCC` | isolated modem supply | 🟡 |

Status legend (same as [../bom/COMPONENT_STATUS.md](../bom/COMPONENT_STATUS.md)):
🟢 LOCKED, 🟡 UNDER EVALUATION, 🔴 NOT SELECTED (source not yet chosen),
⚫ REJECTED.

## 5. Master power table

Sequence numbers are provisional ordering, see section 14.

| Rail | Source | Nominal | Min | Max | Avg current | Peak current | Load | Enable | Sequence | Status |
| --- | --- | ---: | ---: | ---: | ---: | ---: | --- | --- | --- | --- |
| `USB_VBUS` | USB C receptacle | TBD | TBD | TBD | TBD | TBD | PD controller, charger | PD controller | 1 | 🟡 |
| `VBAT` | battery | TBD | TBD | TBD | TBD | TBD | power path | n/a | 1 | 🟡 |
| `VBAT_SYS` | charger / power path | TBD | TBD | TBD | TBD | TBD | SOM power stage, modem isolator, peripheral regulators | TBD (charger / power path) | 2 | 🟡 |
| `VPH_PWR` | SOM power stage from `VBAT_SYS` (TBD) | TBD | TBD | TBD | TBD | TBD | QCS8550 SOM | TBD | 3 | 🔴 |
| `PER_3V3` | TBD regulator from `VBAT_SYS` | 3.3 V | TBD | TBD | TBD | TBD | peripherals, `SE_3V3` LDO | TBD | 4 | 🔴 |
| `PER_1V8` | TBD regulator from `VBAT_SYS` | 1.8 V | TBD | TBD | TBD | TBD | peripherals | TBD | 4 | 🔴 |
| `SE_3V3` | dedicated LDO | 3.3 V | TBD | TBD | TBD | TBD | secure element | `SE_PWR_EN` | 5 | 🟡 |
| `MODEM_VCC` | isolation switch from `VBAT_SYS` | TBD | TBD | TBD | TBD | TBD | 5G modem | `MODEM_PWR_EN` | 5 | 🟡 |

Nominal 3.3 V and 1.8 V are rail definitions. Tolerances and the actual
need come from the selected loads. Every `TBD` must be resolved before
schematic sign off.

## 6. USB_VBUS

```text
USB C receptacle
   ↓
ESD / surge protection
   ↓
PD / power path circuitry
   ↓
USB_VBUS
```

| Parameter | Value |
| --- | --- |
| Nominal voltage | TBD (PD contract) |
| Minimum voltage | TBD |
| Maximum voltage | TBD |
| Input current | TBD |
| PD capability | TBD |
| Reverse current protection | required |
| OVP | required |
| ESD | required |
| TVS | TBD |
| Test point | required |

Consumers: USB C PD controller, charger, power path controller. The USB C
PD architecture must be selected before this rail is locked.

## 7. VBAT

`VBAT` is the physical battery cell domain (`BAT+` to `VBAT`). Chemistry,
cell configuration and protection architecture are TBD. Do not assume the
final battery matches the original Q20 battery.

| Parameter | Value |
| --- | --- |
| Cell count | TBD |
| Chemistry | TBD |
| Nominal voltage | TBD |
| Maximum voltage | TBD |
| Minimum voltage | TBD |
| Capacity | TBD |
| Peak discharge | TBD |
| Protection | required |
| Fuel gauge | TBD |
| Connector | TBD |

## 8. VBAT_SYS

```text
USB_VBUS
    │
    ▼
Charger / power path ──► Battery
    │
    ▼
VBAT_SYS
```

System power path rail. Feeds the system; not an alias for the battery.
Consumers: SOM power stage, modem isolation switch, peripheral regulators,
other system loads.

| Parameter | Value |
| --- | --- |
| Nominal voltage | TBD |
| Minimum voltage | TBD |
| Maximum voltage | TBD |
| Average system current | TBD |
| Peak system current | TBD |
| Reverse blocking | required |
| Current limit | TBD |
| UVLO | TBD |
| OVP | TBD |

## 9. VPH_PWR

Primary power input to the QCS8550 SOM. Never finalized from the QCS8550
SoC datasheet; requirements come only from the selected SOM documentation.

```text
VBAT_SYS ──► [SOM power stage] ──► VPH_PWR ──► QCS8550 SOM
```

Required from SOM documentation: voltage range, maximum current, peak
current, startup behavior, enable, power good, sequencing, shutdown
behavior. Whether a SOM power stage is needed at all, or `VPH_PWR` is fed
directly from `VBAT_SYS`, is TBD.

Status: 🔴. No regulator or switch is selected until this is verified.

## 10. PER_3V3

General 3.3 V peripheral domain. Potential consumers: sensors, GPIO
peripherals, audio peripherals, keyboard controller, trackpad controller,
the `SE_3V3` LDO, other low speed peripherals.

Not every 3.3 V device connects here automatically. Security sensitive or
isolated devices get a dedicated rail.

| Parameter | Value |
| --- | --- |
| Nominal | 3.3 V |
| Min | TBD |
| Max | TBD |
| Average current | TBD |
| Peak current | TBD |
| Regulator | TBD |
| Enable | TBD |
| Sequence | TBD |

## 11. PER_1V8

Main 1.8 V peripheral I/O domain. Potential consumers: SOM interfaces,
GPIO, I²C, SPI, UART, camera control, display control, sensors.

Check the voltage of every interface independently. Never connect a 1.8 V
GPIO to a 3.3 V device without verified compatibility or level
translation.

## 12. SE_3V3

Dedicated secure element power domain.

```text
PER_3V3 ──► dedicated LDO ──► SE_3V3 ──► secure element
```

Default input is `PER_3V3` (handover §19). Feeding the LDO from `VBAT_SYS`
instead is allowed only if the selected LDO and secure element justify it;
record the decision here.

| Parameter | Value |
| --- | --- |
| Nominal voltage | 3.3 V (verify against selected SE MPN) |
| Input | `PER_3V3` (default, TBD until LDO selected) |
| Current | TBD |
| Enable | `SE_PWR_EN` |
| Reset | TBD |
| Decoupling | per LDO and SE datasheets |
| Test point | required |

## 13. MODEM_VCC

```text
VBAT_SYS ──► hardware isolation switch ──► MODEM_VCC ──► 5G modem
```

Intentionally never `VBAT ──► MODEM`. The modem is physically power
isolated.

| Parameter | Value |
| --- | --- |
| Source | `VBAT_SYS` |
| Nominal | TBD (roughly 3.7 V class expected; confirm from modem hardware design guide) |
| Minimum | TBD |
| Maximum | TBD |
| Average current | TBD |
| Peak current | TBD |
| Isolation | required |
| Reverse current blocking | required |
| Enable | `MODEM_PWR_EN` |
| Hardware OFF state | required |
| Test point | required |

The modem MPN must be final before the switch is locked. Current
candidate switch: `TPS22965` (🟡).

## 14. Power sequencing (provisional)

```text
T0  USB / battery detected
T1  charger / power path active
T2  VBAT_SYS valid
T3  SOM power enabled, peripheral regulators enabled
T4  SOM reset released
T5  secure element enabled (SE_PWR_EN); modem remains OFF
T6  Android / Linux boot
T7  modem enabled only when requested (MODEM_PWR_EN)
```

Exact sequencing comes from SOM, PMIC, modem hardware design, secure
element and USB C / charger documentation.

## 15. Hardware modem shutdown

Two separate mechanisms:

```text
Software:  Android ──► modem driver ──► modem shutdown
Hardware:  physical switch / GPIO ──► modem power switch ──► MODEM_VCC
```

The hardware OFF state never depends on Android. The control signal must
not be able to restore modem power while the isolation control is OFF.

## 16. Current budget

```text
Rail peak current = Σ load peak currents × engineering margin
```

Engineering margin: TBD. Never chosen arbitrarily; document the value and
its reason here.

```text
SOM + modem + display + USB + audio + peripherals
═════════════════════════════════════════════════
= system peak
× margin
═════════════════════════════════════════════════
= required regulator capacity
```

Peak, not average, current is the primary value for regulator sizing.

## 17. Power domains

```text
DOMAIN_SYSTEM
├── DOMAIN_SOM
├── DOMAIN_MODEM
├── DOMAIN_SECURITY
├── DOMAIN_USB
└── DOMAIN_PERIPHERAL
```

The separation stays visible in both schematic and PCB.

## 18. Protection requirements

Evaluate each external power domain (`USB_VBUS`, `VBAT`, `VBAT_SYS`,
`MODEM_VCC`, external connectors) for: OVP, UVLO, OCP, SCP, reverse
current, ESD, surge, thermal shutdown, inrush current.

## 19. Decoupling requirements

Every regulator gets input and output capacitors per its datasheet. Every
IC gets local bypass per its datasheet. No generic 100 nF rule.

| Rail | Capacitor value | Package | Voltage rating | Quantity | Placement requirement | Datasheet ref |
| --- | --- | --- | --- | --- | --- | --- |
| | | | | | | |

## 20. Test points

Required: `TP_VBAT`, `TP_VBAT_SYS`, `TP_VPH_PWR`, `TP_PER_3V3`,
`TP_PER_1V8`, `TP_SE_3V3`, `TP_MODEM_VCC`, `TP_USB_VBUS`, `TP_GND`.

Recommended: `TP_SOM_RESET`, `TP_MODEM_PWR_EN`, `TP_POWER_GOOD`.

## 21. Schematic ownership

Power generation belongs to `01_power`. Consumers belong to their
subsystem sheets.

| Rail / domain | KiCad sheet |
| --- | --- |
| `USB_VBUS`, `VBAT`, `VBAT_SYS`, `VPH_PWR`, `PER_3V3`, `PER_1V8`, `SE_3V3`, `MODEM_VCC` | `01_power.kicad_sch` |
| secure element signals | `02_security.kicad_sch` |
| SOM interfaces | `03_soc_som.kicad_sch` |
| modem signals | `04_modem.kicad_sch` |
| USB signals | `05_usb_c.kicad_sch` |

## 22. Open engineering questions

Resolve before power schematic sign off.

**SOM:** exact MPN, input voltage, maximum current, peak current,
sequencing, power good, exposed peripheral rails, connector pinout,
thermal requirements.

**Battery:** chemistry, 1S or multi cell, capacity, peak current,
protection IC, fuel gauge, connector.

**Charger:** USB C PD capability, maximum input current, battery charging
current, power path architecture, OTG / reverse charging, thermal limits.

**Modem:** exact MPN, peak current, interface, M.2 carrier, power switch,
RF requirements, antenna requirements.

**Security:** exact secure element MPN, supply voltage, current, I²C
voltage, reset, interrupt, KeyMint integration, attestation architecture.

**Peripherals:** display voltage, audio codec, keyboard controller,
trackpad controller, camera supplies, sensor supplies.

## 23. Approval criteria

Status moves from DRAFT to APPROVED only when:

* [ ] Every rail has a source
* [ ] Every rail has a load
* [ ] Every rail has voltage limits
* [ ] Every rail has average current
* [ ] Every rail has peak current
* [ ] Every regulator is selected
* [ ] Every regulator has a verified MPN
* [ ] Every regulator has a verified pinout
* [ ] Power sequencing is documented
* [ ] Protection is documented
* [ ] Decoupling is documented
* [ ] SOM power requirements verified
* [ ] Modem power requirements verified
* [ ] Battery architecture selected
* [ ] Charger selected
* [ ] USB C power architecture selected
* [ ] Secure element power verified
* [ ] Test points defined
* [ ] KiCad ownership defined

Until then: `STATUS = DRAFT`.

## 24. Change log

| Date | Change | Author |
| --- | --- | --- |
| 2026-10-08 | Initial Rev A power tree architecture | Q20 Reborn |
| 2026-10-08 | Resolved conflicts with the KiCad handover: canonical names `PER_3V3` / `PER_1V8` (handover §13 `3V3_PER` / `1V8_PER` superseded); all rail generation owned by `01_power`; `MODEM_VCC` nominal set to TBD (roughly 3.7 V expectation kept as a note, Rule 1); `VBAT_SYS` enable set to TBD (no carrier PMIC selected); `SE_3V3` LDO input defaults to `PER_3V3`; status legend aligned to COMPONENT_STATUS | Q20 Reborn |

## 25. Engineering principle

The power tree is the design specification the schematic is built from,
not documentation written after it.

```text
Requirements → power tree → component selection → power calculations
→ KiCad schematic → ERC → PCB → DRC → fabrication → bring up
→ measured power data → update power tree
```

Rev A measurements replace assumptions here. This document stays live
through bring up.
