================================================================================
SESSION 41 - LOADER SLOT/Boot0 WRITE PATH MAPPED (2026-10-23, offline static RE)
================================================================================
Goal: find the os1 slot selector; result: there is none in the flash stream.
The loader-side region machinery and the LAL (boot-slot bookkeeping) are now
mapped; the boot0 write path in THIS loader build is dead code.

------------------------------------------------------------------------------
[1] PreFlash payload: fixed, no slot selector (bb10mt binary RE)
------------------------------------------------------------------------------
unit__bbloader_tbbloader.preflash_byte_tbytes (x86_64, sym at 0x100083380):
  36 zero bytes; d[0]=family ($15 Classic / $40 Passport), d[1]=$28, d[6]=$02,
  d[28]=$01, d[32]=$02; sent as channel2(0x20EE). Response expected word 0x39,
  else "Error in PreFlash". (The live probe saw response cmd 0x20DE, not 0x39;
  still unexplained, note in [5].)

[2] QCFM container: per-entry type only, no slot field (bb10mt qcfm RE)
------------------------------------------------------------------------------
packmfcq builds per-file chunks: "qcfp" hdr + "pfcq" subheader (44 B) + "rrcq"
entries (16 B each: "rrcq", len 0x10, block#, count). pfcq fields:
  [0x00]"pfcq" [0x04]=0x20000 [0x08]=size [0x0c]=TYPE [0x10]=0x2c [0x14]=count
The TYPE comes from the file extension via Ext2Type. No region/slot byte.

[3] RAM loader (loader_9600270A-00.bin, ARM Thumb-2 @ 0x80200000) command map
------------------------------------------------------------------------------
Main flash loop = fcn.80216eec (from loader entry 0x80200050). Command byte at
[r6]+2 (low byte of the wire cmd) dispatches:
  switch tables at 0x802174f0 (0xAF..0xB6), 0x8021751c (0xB7..0xCD),
  0x80217584 (0xCE..0xF6). Handlers:
    fcn.802035f0  = info retrievals (0x20, 0x39/0x3A, 0x50, 0xAB/0xAD, 0xB7,
                    0xD3, 0xDD FLASH_DUMP, 0xE5 CREAD, 0xF5 ...)
    fcn.802030f0  = 0xDA, 0xDB, 0xDC DO_CRC_VERIFY, 0xE1
    fcn.80204048  = sub-dispatcher: 0xAE, 0xAF, 0xB3 (LAL!), 0xB4, 0xBD, 0xBE,
                    0xBF, 0xC3, 0xC4 READVERIFY, 0xC6 FACTORY_WIPE, 0xD1,
                    0xD5, 0xD7 SetActiveMCT, 0xDA, 0xDE, 0xE0, 0xE8, 0xE9
    fcn.80220a58  = 0xEE (PreFlash/ERASE_SECTOR) + 0xEF + the F7 stream:
                    parses the pfcq/rrcq container ("pfcq"/"rrcq" magic checks
                    at 0x80220c78/0x80220ca8), block write via fcn.80231800 /
                    fcn.80202274, region cursors in the sb struct
    fcn.802213a4  = 0xF0
    fcn.80221b98  = 0xC7
    fcn.80221cb0  = 0xC8 GRS_WIPE
    fcn.80220a58 preflash head: reads MBR entry (kind 0x34); if its byte2 ==
                    0xF8 -> falls back to the kind-0x35 region-1 OS MCT entry
                    via fcn.802177e8 ("Unable to find QNX OS MCT entry for
                    region %i"; region byte at entry+3, start at entry+4)

[4] The LAL = the flash-time boot-slot bookkeeping (NEW)
------------------------------------------------------------------------------
fcn.80218c30(arg1, buf, out): arg1==0 -> READ the LAL (flash block 0x2033,
0xFA0 bytes into 0x8FB60190); arg1!=0 -> fcn.80200a70(buf) = WRITE: reads
block 0x2033, PREPENDS buf (a "D:<hex>" text entry) to the LAL, writes it back
(fcn.80208e18). "failed to update LAL" on error.
Two triggers:
  * main loop 0x80217430: after the first command of a flash session, the
    loader prepends "D:00000115" to the LAL AUTOMATICALLY (no host command).
  * command 0xB3 (ramloadercommands.txt mislabels it "Loader Action Log" -
    it is the LAL UPDATE command; payload [0]=state, [8..]=data; responds 0xB4
    with (result+4)&0xFFFF).
=> The macOS lane already updates the LAL on every flash (automatic). The
   boot-side consumer of the LAL is what remains unread (likely SBL picks the
   OS set from the LAL's newest entry, or from boot0's MCT copy - the D7 flip
   negative says boot0).

[5] Boot0 write path in the Classic loader: DEAD CODE
------------------------------------------------------------------------------
"SDSendMMCSpecialVendorCmdWithDataWrite" (VA 0x80238920) and
"SDSendMMCSpecialVendorCmdWithDataRead" (VA 0x8020fd60) have ZERO references
in loader_9600270A-00.bin (no movw/movt pairs, no literal pools, no pc-rel
adds). The vendor-cmd write path is compiled but unreachable in this build.
The bootrom machinery that IS live: fcn.80218714 (load/verify backup bootrom,
"Bootrom too large to fit into buffer", magic 0xD7B02D1F at +0x34) driven by
CREAD (E4/E5); bootrom block read via fcn.80219a34. HASH_BOOTROM = 0xB7.
=> No wire command in this loader writes the hardware boot0 partition. The
   F7 stream addresses the user area only (region cursors from the MCT).

[6] Where this leaves the quest
------------------------------------------------------------------------------
* The os1 selector: none exists. The flash stream targets the region the
  loader computes from the device MCT (MBR / region-1 entry) + the LAL.
* The D7 negative stands: boot-time slot selection is the boot0 MCT copy.
* Boot0 write remains the wall. On the Classic the WP is temporary
  (ext_csd[173]=0x04 B_PWR_WP_EN, BOOT_CONFIG_PROT=0, session 7q): a CMD6
  SWITCH (arg 0x03AD0000) clears it per power-on session. Options:
  (a) a loader whose vendor-cmd write is reachable (check other loaders:
      loader_04002E0A-00.bin per session15, or the Passport 8D002C0A one);
  (b) OS-side raw MMC via IOPRIV/SDHCI user-space (needs uid-0 first);
  (c) the official-updater path gated by NV 0x2019 bits (session 15).
* Live check pending (device offline): re-run PreFlash and log the response
  bytes; the 0x39-vs-0x20DE discrepancy may matter (bb10mt raises on it).
==============================================================================
