# Radio isolation

Kill switches are physical controls driving load switches, not software
toggles. Switch OFF means the subsystem physically loses power.

```text
                ┌──────────────┐
                │ PHYSICAL     │
                │ SWITCH       │
                └──────┬───────┘
                       │
                ┌──────▼──────┐
                │ POWER /     │
                │ DATA SWITCH │
                └──────┬──────┘
                       │
              ┌────────▼────────┐
              │     MODEM       │
              └─────────────────┘
```

## Targets

* Cellular: switch OFF means the modem physically loses power
* Wi-Fi/BT: switch OFF means the radio subsystem physically loses power
* Microphone: switch OFF means mic bias and data path physically
  disconnected
* Camera: switch OFF means camera power physically disconnected

## Design notes

* Load switches sized per subsystem, with a known current ceiling
  (ponytail: single load switch per rail, reassess for inrush on RF PAs)
* Switch state readable by the OS so software behavior matches physical
  state (e.g. airplane mode, mic unavailable)
* No default on state at boot for radios unless user selects it
