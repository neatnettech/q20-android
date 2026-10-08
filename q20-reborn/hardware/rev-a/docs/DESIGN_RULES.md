# Rev A design rules

## Tool versions

| Item | Value |
| --- | --- |
| KiCad version | 10.0.7 |
| Operating system | macOS 26 |
| Schematic format | KiCad native |
| PCB format | KiCad native |

Do not mix major KiCad versions. Opening the project in a newer KiCad is a
deliberate upgrade in its own commit, never mixed with design changes.

## Symbols

* Never design from a conceptual symbol. Generic symbols are allowed only
  during architecture exploration and never reach production schematics.
* Prefer the manufacturer symbol. Verify pin by pin against the datasheet.

## Footprints

Priority: manufacturer footprint, KiCad official library, verified third
party. Never trust a footprint because it looks correct.

Verify: pad numbering, pad dimensions, pitch, outline, courtyard, thermal
pad, solder mask, paste, orientation. Explicit datasheet comparison for
BGA, WLCSP, QFN, LGA, M.2, FPC.

## Annotation

| Prefix | Type |
| --- | --- |
| U | ICs |
| R | resistors |
| C | capacitors |
| L | inductors |
| D | diodes |
| Q | transistors |
| J | connectors |
| F | fuses |
| SW | switches |
| TP | test points |

Reference ranges by subsystem: 1xx power, 2xx security, 3xx SOM, 4xx
modem, 5xx USB C, 6xx display, 7xx keyboard/trackpad, 8xx audio, 9xx
cameras, 10xx debug. Examples: U101 power controller, U201 secure element,
U301 SOM, U401 modem, U501 USB C controller.

## Net naming

Explicit function names: `VBAT`, `VBAT_SYS`, `MODEM_VCC`, `SE_3V3`,
`PER_3V3`, `PER_1V8`, `USB_VBUS`, `USB_CC1`, `USB_CC2`, `I2C_SEC_SCL`,
`I2C_SEC_SDA`, `MODEM_PWR_EN`, `SE_PWR_EN`. Canonical rail names live in [POWER_TREE.md](POWER_TREE.md) §4. Never `POWER1`, `NET1`, `Net(U3 Pad7)`,
`foo`, `temp`.

Power symbols for global power nets. Explicit labels where domain
separation matters: `+3V3` is not `SE_3V3`. A dedicated regulator means a
dedicated net name.

## ERC

`PWR_FLAG` only where ERC needs an explicit power source, never to silence
warnings. ERC clean before schematic approval. Every exception is logged
here with a reason.

| Sheet | ERC message | Reason | Reviewed by |
| --- | --- | --- | --- |
| all (skeleton) | 160 x `label_dangling` | Gate 0 skeleton has no components, so no net contains a component pin. Expected until symbols are placed; must reach zero before Gate 1. | TBD |

## Decoupling

Per datasheet for every IC, never a generic 100 nF everywhere. Record
value, package, voltage rating, quantity and placement per power domain in
POWER_TREE.md.

## Stackup

No routing until manufacturer and stackup are selected.

| Item | Value |
| --- | --- |
| Manufacturer | TBD |
| Layer count | TBD |
| Core thickness | TBD |
| Prepreg | TBD |
| Copper thickness | TBD |
| Controlled impedance | TBD (USB, MIPI DSI, PCIe, modem high speed, RF) |
| Dielectric constants | TBD |
| Via technology | TBD |
| Min trace width / spacing | TBD |
| Drill sizes | TBD |

## Placement order

1. Mechanical: keyboard, trackpad, display connector, USB C, battery,
   antennas, modem, enclosure constraints.
2. SOM: connector, high speed routing, thermal, keepouts.
3. Power: charger, power path, regulators, switches, bulk capacitors near
   loads.
4. High speed: USB, MIPI, PCIe, other differential pairs first.
5. RF: antenna and modem keepouts, RF routing, ground strategy.
6. Low speed: I²C, SPI, UART, GPIO, keyboard, trackpad, sensors.

## Grounding

Continuous reference planes, short return paths, controlled high current
and RF return paths. No plane cuts under differential pairs. No analog
ground islands without a documented reason.
