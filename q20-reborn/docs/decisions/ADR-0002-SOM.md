# ADR-0002: Rev A uses a SOM

Status: accepted

## Context

A flagship SoC on the first PCB means soldering 0.35/0.4 mm pitch parts
before the software and security stack is proven.

## Decision

Rev A is a carrier board around a commercially available SOM (Open-Q
8550CS class), not a direct SoC on PCB. The custom SoC motherboard is
deferred to Rev B.

## Consequences

* Software and security architecture can be proven before the hardest PCB
  problem
* SOM connector and power tree constrain Rev A design
* Rev B later eliminates the SOM at higher PCB complexity (10 to 12+ layer
  HDI)

## Next

Pick the concrete SOM once ADR-0001 (platform) closes.
