# Phone-home inventory (NOD-15, part 1) - 2026-11-05

Live root-SSH reconnaissance on the Classic (192.168.1.184), idle, on Wi-Fi.
Raw captures: pidin/netstat dumps kept locally (regenerable via
`tools/root/q20ssh-root`).

## Smokings guns

- **TIME_WAIT to `23.50.102.29:80` (Akamai, plain HTTP)** seen once at
  inventory time, quiet afterwards. Attribution pending the packet capture
  (the Host header will name it). Suspects: appworld, analyticd, bbads.
- **Confirmed listeners to kill later**: SMB (`smbd`+`nmbd`, ports 139/445 on
  Wi-Fi!), bozohttpd x5 (BB Link endpoints on USB + Wi-Fi :443), mdnsd,
  twonkystarter (DLNA). Pure attack surface for our use case.

## The phone-home kill list

| Process | What it is | Endpoint | Kill method | Risk |
|---|---|---|---|---|
| `analyticd` | BB analytics/telemetry | TBD (capture) | payload slay list | none known |
| `stp_dispatcher` x2 | Service Tools Platform diagnostics upload; handlers: dc, dc-private, memory, power, radio, emmc_health, bluetooth, nfc, qct... | TBD (capture) | payload slay list | none known |
| `pnsagent` x4 | BB push notification agent | BB push (dead infra, retries leak identifiers) | payload slay list | local push dies (we replace later) |
| `bbidd` | BlackBerry ID daemon | BBID auth endpoints | payload slay list | App World sign-in breaks (we do not care) |
| `sys.appworld.*` | BB World storefront client | appworld endpoints | never launch / slay | none |
| `com.rim.bb.app.facebook.*` | bundled FB stub | facebook graph | never launch / slay | none |
| `sys.bbm.*` x2 | BBM | BBM infra (dead) | slay | none |
| `sys.zbbiocm.*` | BB IO connection mgr | TBD | observe in capture first | TBD |
| `bbads` (pps service) | BB advertising | ad endpoints | disable via pps | none |
| `qct_mplogsvc`, `qxdmlogger-msm8960` | Qualcomm diag loggers | local, feeds stp | slay | none |
| `rimlocp` | RIM location proxy | TBD | observe first | location services |
| `omadm`, `cclagent` | carrier device mgmt | carrier endpoints | observe first | carrier provisioning |
| `sys.sysmon.*` | system monitor app | local mostly | leave for now | low |

"Payload slay list" = add to the v8.1 payload's boot re-arm: `slay -f` each
name at every boot. No rcfs edit needed (payload already runs as root).

## Watch items (NOT phone-home, keep)

- `restart -t N -l N` wrappers respawn: pim, videoCore, vpeCore,
  sensor-services, mdnsd, pnsagent, bbio-*... Killing the child alone is
  pointless - kill the `restart` parent too (or the slay list fights forever).
- `dnsp2p` is the local DNS proxy (127.0.0.1:53) - all DNS flows through it,
  good capture point for query logging if the wire capture is awkward.
- `data_miner`, `location_manager/service` - local search/location, revisit
  at hardening time.

## Next (part 2)

The 24h idle packet capture for endpoint attribution + the "zero BB
endpoints" proof: Mac Internet Sharing hotspot, Q20 joined to it,
`tcpdump -i bridge100 host <q20-ip>` on the Mac. Then apply the slay list
and re-capture to prove zero.
