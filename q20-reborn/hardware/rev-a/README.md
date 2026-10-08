# Q20 Reborn Rev A: carrier board

Custom carrier board around a QCS8550 SOM. Engineering validation platform,
not a production phone. Rev A proves the power, security, isolation, debug
and peripheral architecture before Rev B removes the SOM.

## Current state: Gate 0 (architecture), STOP POINT

No schematic capture and no PCB work yet. Immediate deliverables:

1. [docs/COMPONENT_SELECTION.md](docs/COMPONENT_SELECTION.md)
2. [docs/POWER_TREE.md](docs/POWER_TREE.md) (next engineering artifact)
3. [docs/INTERCONNECTS.md](docs/INTERCONNECTS.md)
4. [docs/SECURITY_ARCHITECTURE.md](docs/SECURITY_ARCHITECTURE.md)

KiCad hierarchy is created only after the power tree is reviewed.

## Layout

| Path | Purpose |
| --- | --- |
| `q20-reborn-rev-a.kicad_pro` | KiCad project (create via KiCad GUI, File, New Project; never by hand) |
| `schematic/` | hierarchical sheets `00_top` to `10_debug` |
| `pcb/` | board file |
| `symbols/`, `footprints/`, `3d/` | project libraries, each entry tied to an exact MPN |
| `bom/BOM.csv` | BOM, MPN is authoritative |
| `bom/COMPONENT_STATUS.md` | component status board |
| `docs/` | engineering documents (source of truth with the KiCad files) |
| `docs/concept/` | superseded concept material, reference only |

Planned sheets: `00_top`, `01_power`, `02_security`, `03_soc_som`,
`04_modem`, `05_usb_c`, `06_display`, `07_keyboard_trackpad`, `08_audio`,
`09_cameras`, `10_debug`.

## Non negotiable rules

1. No invented electrical specifications. Unknown is `TBD`.
2. No generic footprints in the final PCB. Every footprint maps to an exact MPN.
3. No symbol is trusted because it looks correct. Verify pin by pin against the datasheet.
4. No power rail without a documented source and load.
5. No security claim without a concrete hardware and software implementation path.
6. Observability and bring up over miniaturization.
7. The SOM is a black box until its manufacturer documentation proves otherwise.
8. The old SN100/TPS22965 concept schematic is reference material only.
9. No PCB size optimization before electrical correctness.
10. Rev A is an engineering validation platform, not a production phone.

No PCB footprint or routing for any component whose exact MPN and datasheet
pinout have not been reviewed.

## Design review gates

| Gate | Required | Allowed after |
| --- | --- | --- |
| 0 Architecture | component selection, power tree, security architecture, interface matrix, mechanical constraints | schematic capture |
| 1 Schematic | exact components, datasheets reviewed, symbols verified, power tree implemented, ERC clean | PCB work |
| 2 PCB | stackup, placement, high speed, power, RF reviewed, DRC clean | fabrication package |
| 3 Manufacturing | BOM, Gerbers, drill, pick and place, assembly drawings, fab notes | order |
| 4 Bring up | rails, current, boot, UART, USB, display, storage, radios, audio, input, cameras, sensors | Rev B |

## Workflow order

COMPONENT_SELECTION, POWER_TREE, INTERCONNECTS, SECURITY_ARCHITECTURE,
`00_top`, `01_power`, `02_security`, `03_soc_som`, remaining sheets, ERC,
placement, routing, DRC, manufacturing package.

## Schematic definition of done

* [ ] All major components selected
* [ ] Exact MPNs recorded
* [ ] Datasheets reviewed
* [ ] Power tree approved
* [ ] All rails documented
* [ ] All major interfaces documented
* [ ] SOM interface verified
* [ ] Modem interface verified
* [ ] USB C architecture verified
* [ ] Secure element architecture verified
* [ ] Hardware isolation architecture verified
* [ ] Symbols verified
* [ ] Footprints verified
* [ ] ERC clean
* [ ] Intentional ERC exceptions documented
* [ ] Test points added
* [ ] Debug interface added
* [ ] Design review completed

## Tooling

KiCad version and policy: [docs/DESIGN_RULES.md](docs/DESIGN_RULES.md).
ERC from the command line:

```bash
/Applications/KiCad/KiCad.app/Contents/MacOS/kicad-cli sch erc schematic/00_top.kicad_sch
```

Related project docs: [../../docs/hardware/POWER.md](../../docs/hardware/POWER.md),
[../../docs/security/](../../docs/security/), [../../docs/decisions/](../../docs/decisions/).
