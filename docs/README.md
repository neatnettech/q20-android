# Documentation

Three layers:

- **[common/](common/)** — the platform-wide technique, identical for every
  device: the flash lane, the runtime root chain, the trusted-inode channel,
  the step-by-step runbook.
- **[../devices/](../devices/)** — per-device knowledge: Classic and P'9983,
  each with its own status, sessions and device-specific gotchas.
- **Narrative history** (this directory): the dated investigation records.

## Common (living knowledge)

| Doc | What it covers |
|---|---|
| [common/runbook.md](common/runbook.md) | step-by-step: flash -> chain -> root -> persistence |
| [common/flash-lane.md](common/flash-lane.md) | bootrom ritual, the bb10mt protocol, the Complete validator |
| [common/root-chain.md](common/root-chain.md) | the carriers/sz/persisted-jobs root technique |
| [common/trusted-inode.md](common/trusted-inode.md) | pathtrust and the /var/exfat trusted-inode exec channel |

## History (the long-form record)

| Doc | Subject |
|---|---|
| [token-wall-and-device-access.md](token-wall-and-device-access.md) | sections 1-27: the whole quest from the token wall to persistent root and A7 |
| [apk-milestones.md](apk-milestones.md) | the A1-A8 ladder for the facade / Android ports |
| [bringup-log.md](bringup-log.md) | the ART runtime bring-up log |
| [handover.md](handover.md) | earlier handover notes |
| [runtime-comparison.md](runtime-comparison.md) | ART-on-QNX vs the stock runtime |
| [hardware.md](hardware.md) | the Q20 hardware reference |

## Devices

See [../devices/](../devices/) - Classic (rooted, persistent, A7 done) and
P'9983 (flashed with the Q10 OS, recovery in progress).
