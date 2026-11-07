#!/usr/bin/env python3
"""Bake the getroot tree from the Classic's UFS into a P'9983 UFS image.

Copies the proven getroot package (device-configuration BAR + fs1.rcfs
impersonation binaries + sshd_config + the installer PPS trigger) so the
first boot after the flash mounts /q - the entry point the root chain
needs. Extends the image past its current end (the ufs stream grows; the
container's rrcq block count must be bumped afterwards).

usage: qnx6_getroot_inject.py <classic-ufs.bin> <navskip-ufs.bin> <out.bin>
"""
import struct, sys
sys.path.insert(0, __import__('os').path.dirname(__import__('os').path.abspath(__file__)))
from qnx6_inspect import QNX6, crc32_be

BS = 4096
DATA = 0x3000
SB = 0x2000
BMP_L1_BLK = 25493
T = 0xF0D80C57          # the stock image's uniform timestamp

# (source path in the Classic ufs, target parent dir, name)
COPY = [
    ('var/android/getroot', 'var/android', 'getroot', 'dir'),
    ('var/android/getroot/META-INF', 'var/android/getroot', 'META-INF', 'dir'),
    ('var/android/getroot/META-INF/MANIFEST.MF', 'var/android/getroot/META-INF', 'MANIFEST.MF', 'file'),
    ('var/android/getroot/assets', 'var/android/getroot', 'assets', 'dir'),
    ('var/android/getroot/assets/links', 'var/android/getroot/assets', 'links', 'file'),
    ('var/android/getroot/assets/perms', 'var/android/getroot/assets', 'perms', 'file'),
    ('var/android/getroot/assets/data', 'var/android/getroot/assets', 'data', 'dir'),
    ('var/android/getroot/assets/data/fs1.rcfs', 'var/android/getroot/assets/data', 'fs1.rcfs', 'file'),
    ('var/etc/ssh/sshd_config', 'var/etc/ssh', 'sshd_config', 'file'),
    ('var/pps/system/installer/upd', 'var/pps/system/installer', 'upd', 'dir'),
    ('var/pps/system/installer/upd/current', 'var/pps/system/installer/upd', 'current', 'dir'),
    ('var/pps/system/installer/upd/current/getroot', 'var/pps/system/installer/upd/current', 'getroot', 'file'),
]

class Target:
    def __init__(self, img):
        self.d = bytearray(img)
        assert len(self.d) > DATA + (BMP_L1_BLK + 0x1000) * BS
        self.magic, self.checksum = struct.unpack_from('<II', self.d, SB)
        assert self.magic == 0x97E6EEDD
        self.num_inodes, self.free_inodes = struct.unpack_from('<II', self.d, SB + 52)
        self.free_blocks = struct.unpack_from('<I', self.d, SB + 64)[0]
        bmp_data = struct.unpack_from('<I', self.d, DATA + BMP_L1_BLK * BS)[0]
        self.bmp = DATA + bmp_data * BS
        self.next_ino = self.num_inodes - self.free_inodes + 1
        self.next_blk = 441799        # first free block past the wizskip additions
        self.allocated = 0

    def bitmap_get(self, blk):
        return (self.d[self.bmp + blk // 8] >> (blk % 8)) & 1

    def bitmap_set(self, blk, val):
        i = self.bmp + blk // 8
        if val:
            self.d[i] |= 1 << (blk % 8)
        else:
            self.d[i] &= ~(1 << (blk % 8))

    def lookup(self, dirino, name):
        raw = self.inode(dirino)
        ptr = struct.unpack_from('<I', raw, 36)[0]
        blk = self.d[DATA + ptr * BS: DATA + (ptr + 1) * BS]
        for off in range(0, BS, 32):
            de = blk[off:off + 32]
            ino, dsize = struct.unpack_from('<IB', de, 0)
            if ino == 0:
                continue
            if de[5:5 + dsize].decode('latin1') == name:
                return ino
        return None

    def lookup_all(self, path):
        ino = 1
        for part in [p for p in path.split('/') if p]:
            nxt = self.lookup(ino, part)
            if nxt is None:
                raise KeyError('missing %r under ino %d' % (part, ino))
            ino = nxt
        return ino

    def alloc_block(self):
        while self.bitmap_get(self.next_blk):
            self.next_blk += 1
        blk = self.next_blk
        self.next_blk += 1
        # extend the image if the block lies past its end
        need = DATA + (blk + 1) * BS
        if need > len(self.d):
            self.d += b'\x00' * (need - len(self.d))
        self.bitmap_set(blk, 1)
        self.allocated += 1
        return blk

    def write_data(self, blk, payload):
        self.d[DATA + blk * BS: DATA + blk * BS + len(payload)] = payload

    def inode(self, ino):
        off = (ino - 1) * 0x80
        return self.d[DATA + (off // BS) * BS + off % BS: DATA + (off // BS) * BS + off % BS + 0x80]

    def write_inode(self, ino, raw):
        off = (ino - 1) * 0x80
        self.d[DATA + (off // BS) * BS + off % BS: DATA + (off // BS) * BS + off % BS + 0x80] = raw

    def make_inode(self, size, mode, ext, ptrs, levels, nlink, uid=0, gid=0, status=1):
        raw = bytearray(0x80)
        struct.pack_into('<Q', raw, 0, size)
        struct.pack_into('<II', raw, 8, uid, gid)
        for i in range(4):
            struct.pack_into('<I', raw, 16 + 4 * i, T)
        struct.pack_into('<HH', raw, 32, mode, ext)
        struct.pack_into('<H', raw, 34, nlink)
        for i, p in enumerate(ptrs):
            struct.pack_into('<I', raw, 36 + 4 * i, p)
        raw[100] = levels
        raw[101] = status
        return bytes(raw)

    def dir_entry(self, ino, name):
        if isinstance(name, str):
            name = name.encode()
        e = bytearray(32)
        struct.pack_into('<I', e, 0, ino)
        e[4] = len(name)
        e[5:5 + len(name)] = name
        return bytes(e)

    def add_entry(self, parent_ino, name, ino):
        raw = self.inode(parent_ino)
        ptr = struct.unpack_from('<I', raw, 36)[0]
        blk = bytearray(self.d[DATA + ptr * BS: DATA + (ptr + 1) * BS])
        slot = None
        for off in range(0, BS, 32):
            if struct.unpack_from('<I', blk, off)[0] == 0:
                slot = off
                break
        assert slot is not None, 'dir %d full' % parent_ino
        blk[slot:slot + 32] = self.dir_entry(ino, name)
        self.d[DATA + ptr * BS: DATA + (ptr + 1) * BS] = blk

    def create_dir(self, parent_ino, name, mode):
        ino = self.next_ino
        self.next_ino += 1
        blk = self.alloc_block()
        raw = self.make_inode(0x1000, mode, 0x0002, [blk] + [0xFFFFFFFF] * 15, 0, 2)
        self.write_inode(ino, raw)
        dblk = bytearray(BS)
        dblk[0:32] = self.dir_entry(ino, b'.')
        dblk[32:64] = self.dir_entry(parent_ino, b'..')
        self.write_data(blk, dblk)
        # bump the parent's nlink + add the entry
        praw = bytearray(self.inode(parent_ino))
        nlink = struct.unpack_from('<H', praw, 34)[0]
        struct.pack_into('<H', praw, 34, nlink + 1)
        self.write_inode(parent_ino, bytes(praw))
        self.add_entry(parent_ino, name, ino)
        return ino

    def create_file(self, parent_ino, name, content, mode):
        ino = self.next_ino
        self.next_ino += 1
        nblk = (len(content) + BS - 1) // BS
        ptrs = [0xFFFFFFFF] * 16
        levels = 0
        if nblk <= 15:
            blocks = [self.alloc_block() for _ in range(nblk)]
            ptrs[:nblk] = blocks
            for j in range(nblk):
                self.write_data(ptrs[j], content[j * BS: (j + 1) * BS])
        else:
            levels = 1
            nl1 = (nblk + 1023) // 1024
            l1s = [self.alloc_block() for _ in range(nl1)]
            ptrs[:nl1] = l1s
            for i in range(nl1):
                count = min(1024, nblk - i * 1024)
                l1 = bytearray(BS)
                for j in range(count):
                    b = self.alloc_block()
                    struct.pack_into('<I', l1, j * 4, b)
                    self.write_data(b, content[(i * 1024 + j) * BS: (i * 1024 + j) * BS + BS])
                for j in range(count, 1024):
                    struct.pack_into('<I', l1, j * 4, 0xFFFFFFFF)
                self.write_data(l1s[i], l1)
        raw = self.make_inode(len(content), mode, 0x0001, ptrs, levels, 1)
        self.write_inode(ino, raw)
        self.add_entry(parent_ino, name, ino)
        return ino

    def finish(self, out):
        struct.pack_into('<I', self.d, SB + 56, self.free_inodes - (self.next_ino - self.num_inodes + self.free_inodes))
        struct.pack_into('<I', self.d, SB + 64, self.free_blocks - self.allocated)
        struct.pack_into('<I', self.d, SB + 4, crc32_be(self.d[SB + 8:SB + 512]))
        open(out, 'wb').write(self.d)
        print('wrote %s (%d bytes, +%d blocks, %d new inodes)' %
              (out, len(self.d), self.allocated, self.next_ino - self.num_inodes + self.free_inodes))

def main():
    src_img = open(sys.argv[1], 'rb').read()
    src = QNX6(src_img)
    t = Target(open(sys.argv[2], 'rb').read())
    dirs = {}   # source path -> ino (source and target dirs share the paths)
    for s_path, parent, name, kind in COPY:
        if kind == 'dir':
            parent_ino = dirs[parent] if parent in dirs else t.lookup_all(parent)
            mode = src.inode_fields(src.lookup_all(s_path))['mode']
            dirs[s_path] = t.create_dir(parent_ino, name, int(mode, 8))
            print('dir  %-50s ino %d' % (s_path, dirs[s_path]))
        else:
            parent_ino = dirs[parent] if parent in dirs else t.lookup_all(parent)
            s_ino = src.lookup_all(s_path)
            f = src.inode_fields(s_ino)
            content = src.read_file(src.inode(s_ino))
            assert len(content) == f['size'], (s_path, len(content), f['size'])
            t.create_file(parent_ino, name, content, int(f['mode'], 8))
            print('file %-50s %d bytes (source ino %d)' % (s_path, len(content), s_ino))
    t.finish(sys.argv[3])

if __name__ == '__main__':
    main()
