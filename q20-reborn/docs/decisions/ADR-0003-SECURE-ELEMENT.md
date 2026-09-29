# ADR-0003: Secure element strategy

Status: open

## Context

The security chain requires a StrongBox class secure element: device
identity, attestation, rollback state, user key storage, brute force
resistance.

## Decision

Pending. A StrongBox class secure element is required; part selection
waits on platform research (ADR-0001) because the keymaster path and
interface (SPI/I2C) depend on the SoC.

## Questions to answer

* Which parts qualify as StrongBox class and are obtainable by
  independents?
* Key provisioning: where does the root key come from, who controls it?
* Anti hammering behavior and lifecycle
* Interface to the platform keymaster

## Consequences

Determines the root of trust layout, the key hierarchy, and what
attestation we can actually provide.

## Next

Fill after ADR-0001 closes; findings from security/BOOT_CHAIN.md feed in.
