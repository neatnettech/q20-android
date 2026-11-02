#!/usr/bin/env python3
"""Inject the wizard-skip state into a stock BB10 user-partition image.

Creates /var/pps/services/firstlaunch/status_public (the exact content and
inode bytes from the proven Classic bake, 2026-10-30) so the first boot
skips OOBE (inprogress::0) and lands on the home screen.

usage: qnx6_wizskip.py <ufs.bin> [out.bin]
"""
import struct, sys

def crc32_be(data, crc=0):
    for b in data:
        crc = ((crc << 8) & 0xFFFFFFFF) ^ tab[((crc >> 24) ^ b) & 0xFF]
    return crc

tab = []
for i in range(256):
    c = i << 24
    for _ in range(8):
        c = ((c << 1) ^ 0x04C11DB7) & 0xFFFFFFFF if c & 0x80000000 else (c << 1) & 0xFFFFFFFF
    tab.append(c)

BS = 4096
DATA = 0x3000
SB = 0x2000
BMP_L1_BLK = 25493       # bitmap L1 (sb Bitmap node ptr[0]); data = L1[0..]
FIRST_FREE_INO = 34837   # num_inodes - free_inodes + 1 (verified zeroed)
SERVICES_INO = 34569     # /var/pps/services in the stock Q10 image
T = 0xF0D80C57           # the image's uniform timestamp (sb atime)

STATUS_PUBLIC = b'@status_public\ninprogress::0'

def main():
    path, out = sys.argv[1], sys.argv[2] if len(sys.argv) > 2 else sys.argv[1] + '.patched'
    d = bytearray(open(path, 'rb').read())
    assert len(d) > DATA + (BMP_L1_BLK + 0x1000) * BS, 'image too small'

    # --- sb sanity
    magic, checksum = struct.unpack_from('<II', d, SB)
    assert magic == 0x97E6EEDD, hex(magic)
    assert checksum == crc32_be(d[SB + 8:SB + 512]), 'sb checksum mismatch'
    num_inodes, free_inodes = struct.unpack_from('<II', d, SB + 52)
    free_blocks = struct.unpack_from('<I', d, SB + 64)[0]

    # --- the inode table: identity-mapped data blocks 0.. (empirically verified)
    def inode_bytes(ino):
        off = (ino - 1) * 0x80
        return d[DATA + (off // BS) * BS + off % BS: DATA + (off // BS) * BS + off % BS + 0x80]

    def write_inode(ino, raw):
        off = (ino - 1) * 0x80
        d[DATA + (off // BS) * BS + off % BS: DATA + (off // BS) * BS + off % BS + 0x80] = raw

    def data_block(blk):
        return d[DATA + blk * BS: DATA + (blk + 1) * BS]

    # --- the block bitmap: L1 @25493 -> data blocks (empirically verified)
    bmp_data = struct.unpack_from('<I', d, DATA + BMP_L1_BLK * BS)[0]
    bmp_off = DATA + bmp_data * BS

    def bitmap_get(blk):
        return (d[bmp_off + blk // 8] >> (blk % 8)) & 1

    def bitmap_set(blk, val):
        i = bmp_off + blk // 8
        if val:
            d[i] |= 1 << (blk % 8)
        else:
            d[i] &= ~(1 << (blk % 8))

    # --- allocate 2 data blocks (dir + file) past the longfile table
    alloc = []
    blk = 441792
    while len(alloc) < 2:
        if not bitmap_get(blk):
            alloc.append(blk)
            bitmap_set(blk, 1)
        blk += 1
    assert blk * BS + DATA <= len(d), 'image too small for new blocks'
    print('blocks:', alloc)

    # --- build the inodes (byte layout mirrored from the Classic bake)
    def make_inode(size, mode, ext, ptr, nlink, status=1):
        raw = bytearray(0x80)
        struct.pack_into('<Q', raw, 0, size)
        for i in range(4):
            struct.pack_into('<I', raw, 16 + 4 * i, T)
        struct.pack_into('<HH', raw, 32, mode, ext)
        struct.pack_into('<H', raw, 34, nlink)
        struct.pack_into('<I', raw, 36, ptr)
        for i in range(1, 16):
            struct.pack_into('<I', raw, 36 + 4 * i, 0xFFFFFFFF)
        raw[101] = status
        return bytes(raw)

    dir_ino, file_ino = FIRST_FREE_INO, FIRST_FREE_INO + 1
    write_inode(dir_ino, make_inode(0x1000, 0x41FF, 0x0002, alloc[0], 2))
    write_inode(file_ino, make_inode(len(STATUS_PUBLIC), 0x81B6, 0x0001, alloc[1], 1))

    # --- firstlaunch dir block: . .. status_public
    def dir_entry(ino, name):
        e = bytearray(32)
        struct.pack_into('<I', e, 0, ino)
        e[4] = len(name)
        e[5:5 + len(name)] = name
        return bytes(e)

    dblk = bytearray(BS)
    dblk[0:32] = dir_entry(dir_ino, b'.')
    dblk[32:64] = dir_entry(SERVICES_INO, b'..')
    dblk[64:96] = dir_entry(file_ino, b'status_public')
    d[DATA + alloc[0] * BS: DATA + (alloc[0] + 1) * BS] = dblk

    # --- file content
    fblk = bytearray(BS)
    fblk[:len(STATUS_PUBLIC)] = STATUS_PUBLIC
    d[DATA + alloc[1] * BS: DATA + (alloc[1] + 1) * BS] = fblk

    # --- add the 'firstlaunch' entry to the services dir (ino 34569)
    svc = inode_bytes(SERVICES_INO)
    svc_ptr = struct.unpack_from('<I', svc, 36)[0]
    nlink = struct.unpack_from('<H', svc, 34)[0]
    struct.pack_into('<H', svc, 34, nlink + 1)
    write_inode(SERVICES_INO, svc)
    svc_blk = bytearray(data_block(svc_ptr))
    slot = None
    for off in range(0, BS, 32):
        if struct.unpack_from('<I', svc_blk, off)[0] == 0:
            slot = off
            break
    assert slot is not None, 'services dir full'
    svc_blk[slot:slot + 32] = dir_entry(dir_ino, b'firstlaunch')
    d[DATA + svc_ptr * BS: DATA + (svc_ptr + 1) * BS] = svc_blk

    # --- sb accounting + checksum
    struct.pack_into('<I', d, SB + 56, free_inodes - 2)
    struct.pack_into('<I', d, SB + 64, free_blocks - 2)
    struct.pack_into('<I', d, SB + 4, crc32_be(d[SB + 8:SB + 512]))

    open(out, 'wb').write(d)
    print('wrote %s (%d bytes)' % (out, len(d)))

if __name__ == '__main__':
    main()
