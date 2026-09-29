# Q20 Reborn

Independent, security first smartphone in the BlackBerry Classic form
factor: physical keyboard and trackpad, replaceable battery, hardware radio
isolation switches, running a GrapheneOS class OS. Separate workstream from
the QNX graft project at the repo root; this is new hardware design, not
reverse engineering.

Status: M0 to M2 (research phase). Requirements drafted, platform selection
in progress. No SoC committed, no money spent on hardware.

## Staged plan

Each stage has an explicit exit criterion. No PCB work before the SoC, boot
chain, and security architecture are proven on development hardware.

| Stage | Phase | Exit criterion |
| --- | --- | --- |
| 00 | Project and documentation | repo and docs exist (done) |
| 01 | Requirements | REQUIREMENTS.md locked |
| 02 | Hardware platform research | one preferred platform + one fallback (current) |
| 03 | Security architecture | threat model and boot chain locked |
| 04 | Development platform | lab hardware running |
| 05 | Peripheral prototyping | Q20 keyboard/trackpad working on bench |
| 06 | Software bring up | own signed OS image boots on dev platform |
| 07 | Rev A carrier board | carrier runs our software stack |
| 08 | Mechanical prototype | enclosure v0 with CNC frame |
| 09 | Rev B custom motherboard | own board boots the full stack |
| 10 | Security hardening | self attack results documented |
| 11 | Production prototype | polished device (Rev C) |
| 12 | Manufacturing | release plan |

## Milestones

| Milestone | Deliverable | State |
| --- | --- | --- |
| M0 | Repository and documentation | done |
| M1 | Requirements locked | drafted |
| M2 | SoC selected | current |
| M3 | Security architecture locked | pending |
| M4 | Development hardware running | pending |
| M5 | Android/AOSP boot | pending |
| M6 | GrapheneOS device bring up | pending |
| M7 | Q20 keyboard/trackpad working | pending |
| M8 | Rev A carrier schematic | pending |
| M9 | Rev A PCB manufactured | pending |
| M10 | Rev A fully operational | pending |
| M11 | CNC enclosure prototype | pending |
| M12 | Rev B custom motherboard | pending |
| M13 | Security audit/testing | pending |
| M14 | Rev C production prototype | pending |

## Documents

| Path | Purpose |
| --- | --- |
| docs/PROJECT.md | goals, scope, principles |
| docs/REQUIREMENTS.md | functional and security requirements |
| docs/ROADMAP.md | roadmap detail |
| docs/architecture/SYSTEM.md | system, board, boot chain |
| docs/hardware/PLATFORM.md | SoC research (current focus) |
| docs/hardware/PERIPHERALS.md | keyboard, trackpad, display |
| docs/hardware/POWER.md | power tree and isolation |
| docs/security/SECURITY.md | security goals and policy |
| docs/security/BOOT_CHAIN.md | boot chain research |
| docs/security/THREAT_MODEL.md | threat model |
| docs/security/RADIO_ISOLATION.md | kill switches |
| docs/decisions/ | ADRs |

## Next action

Platform selection (M1 to M2): research QCS8550, QCM6490, and 2 to 3
contemporary alternatives against the security requirements. Start at
docs/hardware/PLATFORM.md.
