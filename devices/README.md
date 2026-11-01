# Devices

| Device | Model | hwid | Status |
|---|---|---|---|
| [classic/](classic/) | BlackBerry Classic (SQC100) | 9600270A | **rooted, persistent across reboots, A7 compositing done** - `ssh -p 2225 root@<ip>` |
| [p9983/](p9983/) | Porsche Design P'9983 (SQK100-1) | 8F00270A | flashed with the Q10 OS + the flash lane; first-boot hang under investigation |

Common technique: [../docs/common/](../docs/common/) (flash lane, root
chain, trusted-inode channel, runbook). Tooling: [../tools/](../tools/).
