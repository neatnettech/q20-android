# Q20 Reborn: project

## Goal

An independent smartphone in the BlackBerry Classic (Q20) form factor:
ARM64 SoC, physical keyboard and trackpad, replaceable battery, physical
radio isolation, running a GrapheneOS class OS. Not a plastic Q20 replica:
a modern device in the Classic lineage.

## Principles

* Security first. Hardware requirements derive from GrapheneOS class
  security (MTE, StrongBox, AVB, rollback protection, A/B updates), not the
  other way around.
* Prove before PCB. SoC, boot chain, and security architecture must be
  demonstrated on development hardware before any smartphone PCB. Rev A is
  a validation board around a SOM, not the phone.
* Every stage has an exit criterion. See ROADMAP.md.
* Platform accessibility. "Qualcomm lists a feature" is not the same as
  "we can use it as an independent developer". Both must be established
  before money is spent (docs/security/BOOT_CHAIN.md).
* Reproducibility. Reproducible firmware and OS builds, open documentation
  wherever possible.
* Serviceability. Replaceable battery, accessible internals.
* No unnecessary cloud dependency.
* USB debugging physically inaccessible in production, with a documented
  process to disable and remove debug access.

## Relation to the QNX graft project

The repo root hosts the Q20 QNX Android graft effort (runtime/art-qnx,
docs/bringup-log.md). Q20 Reborn is the future hardware track and shares:
Q20 keyboard and trackpad reverse engineering, form factor research, and
the hardware inventory in docs/hardware.md.

## Phases

00 Project and documentation (done)
01 Requirements (done, needs lock)
02 Hardware platform research (current)
03 Security architecture
04 Development platform purchase (first hardware spend, after 02 and 03)
05 Peripheral prototyping
06 GrapheneOS / Android bring up
07 Rev A carrier board
08 Mechanical prototype
09 Rev B custom motherboard
10 Security hardening
11 Production prototype (Rev C)
12 Manufacturing
