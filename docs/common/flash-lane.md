# The flash lane (both devices)

The macOS-only USB flash path. Proved on the Classic (SQC100) and the
P'9983 (SQK100-1, hwid 8F00270A). Tooling: [tools/flash/](../../tools/flash/).

## The bootrom ritual

Fresh `0001` (the PBL) appears only when the device is **off** at plug-in
time: unplug -> power off until dark -> plug in, touch nothing. `8001` is
the resident loader (ignores the F7 stream); a parked `0001` goes stale.
The 50ms edge watcher ([watch_flash.py](../../tools/flash/watch_flash.py))
grabs it instantly.

## The protocol (bb10mt, from `bb10root/bb10mt`)

- channel0: Ping / GetVar(2) -> model_id / SetMode(1) / password exchange
  (HashPassV2), channel1: metrics / RAM upload / execute.
- FlashFile: PreFlash(family) -> F7 block stream -> 40F9 signature ->
  40C0 Complete. **The F7 handler pre-acks 0xDF then queues a post-ack
  packet; every send needs a drain read or the next write NAKs forever.**
- `libusb_set_configuration(1)` on reopen is mandatory for the Q10-family
  bootrom (device comes up unconfigured when the loader takes over).

## Loaders

| hwid | loader | note |
|---|---|---|
| 9600270A (Classic) | loader_9600270A-00.bin | == bb10mt LDR_00, the generic 270A loader |
| 8F00270A (P'9983) | loaders/loader_8F00270A-00.bin | == loader_8700080A (LDR_67); every other loader hangs at SetMode(2) |

`probe_loaders.py` tests candidates end-to-end (upload -> SetMode(2)).

## Containers

The cap.exe autoloader = PE stub + ver2 header (10.3.3.498 builds prefix
it with 0x3C bytes) + mfcq containers. `extract_autoloader.py` pulls
ifs/radio/os.signed. Flash order: IFS -> OS -> radio; **never end a
session on a rejected Complete (402E) or the device red-blinks**
(`flash_radiofix.sh` cures it).

## The Complete validator

40C0 -> 4006 (commit) or 402E (reject): NV 0x2819==0 and 0x2852==0, a
device-state word in {0,3}, plus a TLV-0x85 payload struct (magic
0xe276ca03). The UFS (user partition) is NOT signature-gated: a modified
OS container gets 402E on the rcfs commit but its User stream lands -
that is how the pre-rooted user image works (P'9983).
