# Peripherals

## Q20 keyboard and trackpad

The Classic keyboard PCB (CB-46495-002_1, controller MFC3 3415, see repo
root docs/hardware.md) is a capacitive key and trackpad assembly.

Bench plan (phase 05):

```text
Q20 keyboard
      │
      ▼
RP2040 / MCU
      │
      ▼
USB / I²C
      │
      ▼
Development board
```

Test: key matrix, trackpad, backlight, buttons, LED.

Target architecture: a keyboard MCU owns the matrix, backlight, trackpad,
and special buttons, talking I2C/SPI to the SoC, so the Android driver
stays clean (see architecture/SYSTEM.md). Existing open source Q20
keyboard reverse engineering work is the starting point.

## Display

Determine whether the original 2014 LCD is worth retaining. If not,
replace it: no reason to compromise the whole project for an old panel.
Target: a modern MIPI DSI panel.

## Cameras

MIPI CSI. Power kill switchable (see security/RADIO_ISOLATION.md).

## Audio

Speaker, microphone (kill switchable bias and data path), 3.5 mm jack.
