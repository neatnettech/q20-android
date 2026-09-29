# Q20 Reborn: roadmap

## Milestones

| Milestone | Deliverable |
| --- | --- |
| M0 | Repository and documentation |
| M1 | Requirements locked |
| M2 | SoC selected |
| M3 | Security architecture locked |
| M4 | Development hardware running |
| M5 | Android/AOSP boot |
| M6 | GrapheneOS device bring up |
| M7 | Q20 keyboard/trackpad working |
| M8 | Rev A carrier schematic |
| M9 | Rev A PCB manufactured |
| M10 | Rev A fully operational |
| M11 | CNC enclosure prototype |
| M12 | Rev B custom motherboard |
| M13 | Security audit/testing |
| M14 | Rev C production prototype |

## Current position

M0 complete (this tree). M1 requirements drafted, needs a lock pass.
M2 platform selection is the active task.

## What to do right now

1. Research QCS8550, QCM6490, and 2 to 3 contemporary alternatives
   against the criteria in docs/hardware/PLATFORM.md
2. Fill the boot chain accessibility questions in
   docs/security/BOOT_CHAIN.md
3. Close ADR-0001 with one preferred platform and one fallback
4. Then order the development platform (M4) and start device/kernel work
   in parallel with hardware design

No PCB work until M2 and M3 are locked.
