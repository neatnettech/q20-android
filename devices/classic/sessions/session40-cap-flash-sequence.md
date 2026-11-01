# Session 40 - cap.exe flash sequence mapped (the missing flash-time state)

Static rizin analysis of cap_patched.exe (RIM CFP 3.11.0.27). Goal: the delta
between cap.exe's flash and bb10mt's, which makes the SBL accept the OS.

## Wire framing (fcn.0045be30)

frame = [size:2 LE][cmd_lsb:1][cmd_msb:1][payload][crc:4], size = 8 + payload.
Identical to bblink's channel2. The commands (16-bit LE words):

| command | bytes | purpose (log string) |
|---|---|---|
| 0x40F9 | F9 40 | SIGNATURE_TRAILER |
| 0xF6F1 | F1 F6 | UPGRADE_MCT_TO_RESIZABLE |
| 0xF9F6 | F6 F9 | DOWNGRADE_MCT_FROM_RESIZABLE |
| 0xBDD0 | D0 BD | ADD_BOOT1_MCT ("Adding boot1 partition to MCT") |
| ERASE_SECTOR, ERASE_ALL_MCT (F3), ADD_OS_EXTENDED (E3), REMOVE_INSTALLER (E0),
  DO_CRC_VERIFY (DC), HASH_BOOTROM (B7), COMPLETE (40C0), Freshness Seal, RTAS
  permission | | the rest of the inventory |

## The flow (CFP_Imp virtual methods)

* virtual_116 @ 0x40d300 = "QNXLOAD": the per-image flash. It virtual-dispatches
  the actual load (the F7 block stream) then calls fcn.0044c640 = the 40F9
  SIGNATURE_TRAILER. This matches bb10mt's FlashFile.
* virtual_84 @ ~0x40c160 = the MCT downgrade orchestration (fcn.0040c3b0 ->
  fcn.0044b900 sends 0xF9F6).
* virtual_308 = ADD_BOOT1_MCT (fcn.0044b810 -> fcn.0044bde0 sends 0xBDD0).
* virtual_260 @ 0x40d910 = the ERASE_ALL_MCT + the upgrade 0xF6F1
  (fcn.00446450).

## The hypothesis

The slot commit = the ADD_BOOT1_MCT (0xBDD0): cap.exe adds the boot1 eMMC
partition entry to the device's MCT at flash time ("Boot1 MMC: blocks %d-%d,
total = %d, flags = 0x%04X"). The boot path reads this entry; the bb10mt lane
never sends it, so the flashed RCFS never becomes the booted copy. The payload
= the boot1 block range + the flags, pre-filled in the CFP struct
([esi+0x1401e] = the size field).

## The bblink plan

1. Add the commands: upgrade_mct(0xF6F1), downgrade_mct(0xF9F6),
   add_boot1_mct(0xBDD0).
2. The boot1 block range: derive from the device MCT (captured) + the stanw47
   boot1 dump info; the flags = 0.
3. Replay: the PreFlash -> the ADD_BOOT1_MCT -> the QNXLOAD F7 stream ->
   the 40F9 -> the 40C0 -> the reboot. Test whether the modified RCFS boots.

## Session 40b - live probe results (fresh loader, 2026-10-22)

* The three commands fired against the bootrom-uploaded fresh loader:
  * F6F1 (upgrade MCT to resizable) -> resp cmd 0x15F6 + status 0x04
  * F9F6 (downgrade MCT to dynamic) -> resp cmd 0x15F9 + status 0x04
  * BDD0 (ADD_BOOT1_MCT) -> resp cmd 0x15BD + status 0x04
  * The payload makes no difference (empty / MCT head / full 976-byte MCT =
    all 0x04). The D7 (SetActiveMCT) and the E3 (ADD_OS_EXTENDED) return
    the clean 0x15 with no status.
* The status 0x04 = the refusal, not the success (the cap.exe treats the
  nonzero return as the error path; the 0x6c = the busy). The candidate
  meanings: "MCT: entry overlaps another" or "MCT: entry in write
  protected flash".
* The MCT structure re-confirmed live: the [type_flags:2][flags:2]
  [name:12][start:4][end:4] entries, the two OS sets (A @ 0x0820,
  B @ 0x2820), the radio @ 0x4820, the user @ 0x5820. A leading
  section of 0xFFFF-marked entries (@12..104) precedes the named
  partitions - the likely the boot-region table.
* The remaining static target: what fills [CFP_Imp+0x20] (the tx buffer)
  and [CFP_Imp+0x1401e] (the payload size) before the ADD_BOOT1_MCT send.
  The boot1 entry payload = the block range + the flags per the
  "Boot1 MMC: blocks %d-%d, total = %d, flags = 0x%04X" log format.

## Session 40c - more live probes (same loader session)

* E0 (REMOVE_INSTALLER) -> resp cmd 0xC3 + 0x00. The cleanest success-shaped
  response seen yet.
* DC (DO_CRC_VERIFY, os-A range 0x820..0x121f) -> resp cmd 0xCE + 0x03.
* E3 (ADD_OS_EXTENDED) -> clean 0x15 with no status, any payload.
* PreFlash (0x20EE, 0x15) -> responds, but with cmd 0x20DE, not the 0x39
  the protocol notes expect; the response payload = 0x01000000.
* F7 = STILL unacknowledged even after the PreFlash. The F7 silence is not
  a missing-PreFlash artifact. The fresh loader answers every other
  command but drops the F7 block writes.
