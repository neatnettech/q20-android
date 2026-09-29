# Q20 Reborn: system architecture

## Rev A: SOM carrier

Rev A is the platform validation board, not the phone: a QCS8550 class SOM
on our carrier, proving the software and security stack before the hardest
PCB problem.

```text
┌──────────────────────────────────────────┐
│                 REV A                    │
│                                          │
│             QCS8550 SOM                  │
│   SoC / LPDDR5X / UFS / PMIC             │
│                                          │
│   USB-C   HDMI/DP   Debug header         │
│                                          │
│   Display  Keyboard  Trackpad            │
│   Audio    Camera    WiFi                │
│   Modem    Secure Element                │
│   Kill switches                          │
└──────────────────────────────────────────┘
```

## Rev B: own motherboard

Eliminates the SOM: SoC, LPDDR5X, UFS, PMIC, secure element, radios, and
peripherals on our PCB. Likely a 10 to 12+ layer HDI PCB. Not cost
optimized: correctness first.

```text
                    REV B
               ┌─────────────┐
               │ ARM64 SoC   │
               └──────┬──────┘
                      │
        ┌─────────────┼─────────────┐
        │             │             │
      RAM            UFS           PMIC
        │             │             │
        └─────────────┼─────────────┘
                      │
        ┌─────────────┼──────────────┐
        │             │              │
      Display       Radio          Security
        │             │              │
     MIPI DSI      modem       Secure Element
        │             │              │
      Camera      WiFi/BT           RoT
```

## Secure boot chain

```text
                    USER
                     │
                     ▼
             ┌──────────────┐
             │ LOCKED BOOT  │
             └──────┬───────┘
                    │
              Hardware RoT
                    │
          ┌─────────▼─────────┐
          │   Secure Element  │
          │ Device identity   │
          │ Attestation       │
          │ Rollback state    │
          │ User key          │
          │ Brute force       │
          │ resistance        │
          └─────────┬─────────┘
                    │
              Verified Boot
                    │
          ┌─────────▼─────────┐
          │     Firmware      │
          │      A/B          │
          └─────────┬─────────┘
                    │
                  AVB
                    │
          ┌─────────▼─────────┐
          │    GrapheneOS     │
          │       A/B         │
          └───────────────────┘
```

Bootloader unlock is an intentional security state transition, never
permanently open.

## Keyboard subsystem

```text
                KEYBOARD
                    │
                    ▼
             Keyboard MCU
                    │
                I²C / SPI
                    │
                    ▼
                 SoC
```

The MCU owns the key matrix, backlight, trackpad, and special buttons so
the Android driver stays clean. Open source Q20 keyboard reverse
engineering work is the starting point.

## Physical stack

```text
┌────────────────────────────┐
│          DISPLAY           │
├────────────────────────────┤
│          BATTERY           │
├────────────────────────────┤
│          MAIN PCB          │
├────────────────────────────┤
│      KEYBOARD + TRACKPAD   │
└────────────────────────────┘
```
