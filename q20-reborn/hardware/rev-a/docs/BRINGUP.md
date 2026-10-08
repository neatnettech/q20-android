# Rev A bring up

Never power an unverified board from the final battery pack. First power
on uses a bench PSU with current limiting and has a known voltage, known
current limit, known measurement points and known shutdown procedure.

## Sequence

1. Visual inspection
2. Continuity checks
3. Check shorts to GND
4. Set power supply current limit
5. Verify primary rail
6. Verify regulator outputs
7. Verify sequencing
8. Verify SOM power
9. Verify reset
10. Verify boot UART
11. Boot SOM
12. USB
13. Storage
14. Display
15. Peripherals
16. Modem
17. Radios
18. Security features

## Test points

Required: GND, VBAT, VBAT_SYS, SOM power input, PER_3V3, PER_1V8, SE_3V3,
MODEM_VCC, USB_VBUS.

Where practical: UART_TX, UART_RX, RESET, BOOT, POWER_GOOD, MODEM_PWR_EN.

Testability beats saving board area on Rev A.

## First power on record

| Item | Value |
| --- | --- |
| PSU voltage | TBD |
| Current limit | TBD |
| Expected idle current | TBD |
| Shutdown procedure | TBD |

## Gate 4 checklist

* [ ] power rails
* [ ] current consumption
* [ ] boot
* [ ] UART
* [ ] USB
* [ ] display
* [ ] storage
* [ ] modem
* [ ] WiFi
* [ ] Bluetooth
* [ ] audio
* [ ] keyboard
* [ ] trackpad
* [ ] cameras
* [ ] sensors
