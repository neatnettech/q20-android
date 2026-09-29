# ADR-0001: SoC platform selection

Status: open

## Context

Q20 Reborn needs a SoC satisfying GrapheneOS class security requirements
(MTE, StrongBox, AVB, rollback protection, A/B updates) with an Android
BSP and firmware accessible to an independent developer.

## Decision

Pending. Evaluate QCS8550, QCM6490/QCS6490, and 2 to 3 contemporary
alternatives against the criteria in hardware/PLATFORM.md.

## Criteria

See hardware/PLATFORM.md: security criteria (hard) plus integration
criteria (BSP, firmware, kernel source, documentation, SOM availability,
lifecycle, cost).

## Consequences

The choice drives the BSP, firmware access, secure element strategy, SOM
options for Rev A, and the Rev B PCB design.

## Next

Fill hardware/PLATFORM.md findings, then close with one preferred platform
plus one fallback (M2 exit criterion).
