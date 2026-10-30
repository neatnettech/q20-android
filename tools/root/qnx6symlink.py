#!/usr/bin/env python3
"""Inject SYMLINK entries into the qnx6 image: each entry links a name in the
mounted fs to a trusted-dev/ino target (the Android subsystem dir), so
pathtrust accepts the exec-as-root. Same layout as qnx6inject.py."""
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

def main(out, linkspecs):
    import os
    stage = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'stage.qnx6')
    d = bytearray(open(stage, 'rb').read())
    specs = []
    for spec in linkspecs:
        name, target = spec.split('=', 1)
        assert len(name) < 27
        specs.append((name, target.encode()))

    def free_blocks():
        for bit in range(2032):
            if not (d[0x3000 + bit // 8] & (1 << (bit % 8))):
                yield bit

    fb = free_blocks()
    allocs = [(name, tgt, [next(fb)]) for name, tgt in specs]

    t = struct.unpack_from('<I', d, 0x2000 + 16)[0]
    ino = 3
    for name, tgt, (blk,) in allocs:
        off = INOTBL + (ino - 1) * 0x80
        struct.pack_into('<Q', d, off, len(tgt))
        struct.pack_into('<II', d, off + 8, 0, 0)
        for i in range(4):
            struct.pack_into('<I', d, off + 16 + 4 * i, t)
        struct.pack_into('<H', d, off + 32, 0xA1FF)   # S_IFLNK | 0777
        struct.pack_into('<H', d, off + 34, 1)        # nlink
        struct.pack_into('<16I', d, off + 36, *([blk] + [0xFFFFFFFF] * 15))
        d[off + 100] = 0
        d[off + 101] = 3                              # status: normal (symlink via mode)
        d[BASE + blk * BLK: BASE + blk * BLK + len(tgt)] = tgt
        d[0x3000 + blk // 8] |= 1 << (blk % 8)
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
        print("symlink inode %d '%s' -> %s" % (ino, name, tgt.decode()))
        ino += 1

    for SB in (0x2000, 0x1FF000):
        struct.pack_into('<I', d, SB + 0x38, 252)
        struct.pack_into('<I', d, SB + 0x40, 1959)
        d[SB + 4:SB + 8] = struct.pack('<I', crc32_be(d[SB + 8:SB + 512]))

    open(out, 'wb').write(d)
    print("wrote", out, len(d))

if __name__ == '__main__':
    sys.exit(main(sys.argv[1], sys.argv[2:]))
