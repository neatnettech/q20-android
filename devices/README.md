# Devices

| Device | Model | hwid | Status |
|---|---|---|---|
| [classic/](classic/) | BlackBerry Classic (SQC100) | 9600270A | **rooted, persistent across reboots, live facade (A8) and A9 natives done** - `ssh -p 2225 root@<ip>` |
| [p9983/](p9983/) | Porsche Design P'9983 (SQK100-1) | 8F00270A | **rooted 2026-11-06** (uid-0 on 2225, self-healing persistence) |

Common technique: [../docs/common/](../docs/common/) (flash lane, root
chain, trusted-inode channel, runbook). Tooling: [../tools/](../tools/).
