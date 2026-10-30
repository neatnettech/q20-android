#!/usr/bin/env python3
"""Inject files into the device-made empty qnx6 image (stage.qnx6).
Layout empirical (verified): sb @0x2000 + backup @0x1FF000; checksum
crc32_be(init0) over sb[8:512]; block N @ 0x3000 + N*1024; block bitmap
@0x3000 (bit N set = used); inode table @0x3800, inode N @ 0x3800 +
(N-1)*0x80 (size u64@0 uid@8 gid@12 times@16..28 mode u16@32 nlink u16@34
ptr[16] u32@36 filelevels@100 status@101); root dir = inode 1, block 68
(@0x14000), 32-byte entries [inode:4][size:1][name:27].
"""
import struct, sys

BLK = 1024
BASE = 0x3000
INOTBL = 0x3800
ROOTDIR = 0x14000

tab = []
for i in range(256):
    c = i << 24
    for _ in range(8):
        c = ((c << 1) ^ 0x04C11DB7) & 0xFFFFFFFF if c & 0x80000000 else (c << 1) & 0xFFFFFFFF
    tab.append(c)

def crc32_be(data, crc=0):
    for b in data:
        crc = ((crc << 8) ^ tab[((crc >> 24) ^ b) & 0xFF]) & 0xFFFFFFFF
    return crc

def main(out, files):
    d = bytearray(open('stage.qnx6', 'rb').read())
    payloads = [(open(f, 'rb').read(), f.rsplit('/', 1)[-1]) for f in files]
    for p, name in payloads:
        assert len(name) < 27, "name too long: %s" % name

    def free_blocks():
        for bit in range(2032):
            if not (d[0x3000 + bit // 8] & (1 << (bit % 8))):
                yield bit

    fb = free_blocks()
    allocs = []
    for p, name in payloads:
        nblk = (len(p) + BLK - 1) // BLK
        allocs.append((name, p, [next(fb) for _ in range(nblk)]))

    t = struct.unpack_from('<I', d, 0x2000 + 16)[0]   # sb ctime as file times
    ino = 3
    for name, p, blocks in allocs:
        off = INOTBL + (ino - 1) * 0x80
        struct.pack_into('<Q', d, off, len(p))
        struct.pack_into('<II', d, off + 8, 0, 0)
        for i in range(4):
            struct.pack_into('<I', d, off + 16 + 4 * i, t)
        struct.pack_into('<H', d, off + 32, 0x81ED)   # S_IFREG | 0755
        struct.pack_into('<H', d, off + 34, 1)        # nlink
        struct.pack_into('<16I', d, off + 36, *([blocks[0]] + [0xFFFFFFFF] * 15))
        d[off + 100] = 0                              # filelevels
        d[off + 101] = 3                              # status: normal file
        for j, b in enumerate(blocks):
            chunk = p[j * BLK:(j + 1) * BLK]
            d[BASE + b * BLK: BASE + b * BLK + len(chunk)] = chunk
            d[0x3000 + b // 8] |= 1 << (b % 8)
        slot = None
        for k in range(0, BLK, 32):
            if all(x == 0 for x in d[ROOTDIR + k: ROOTDIR + k + 5]):
                slot = k
                break
        assert slot is not None, "root dir full"
        e = bytearray(32)
        struct.pack_into('<I', e, 0, ino)
        e[4] = len(name)
        e[5:5 + len(name)] = name.encode()
        d[ROOTDIR + slot: ROOTDIR + slot + 32] = e
        print("inode %d '%s' %d bytes, blocks %s" % (ino, name, len(p), blocks))
        ino += 1

    for SB in (0x2000, 0x1FF000):
        struct.pack_into('<I', d, SB + 0x38, 252)   # free_inodes (was 254, -2)
        struct.pack_into('<I', d, SB + 0x40, 1959)  # free_blocks (was 1962, -3)
        d[SB + 4:SB + 8] = struct.pack('<I', crc32_be(d[SB + 8:SB + 512]))

    open(out, 'wb').write(d)
    print("wrote", out, len(d))

if __name__ == '__main__':
    sys.exit(main(sys.argv[1], sys.argv[2:]))
