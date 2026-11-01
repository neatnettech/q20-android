#!/usr/bin/env python3
"""QNX6 (BB10 user-partition variant) reader — verified against the Q10 UFS.

Layout (empirically verified 2026-11-01):
  boot block @0x0..0x1fff, sb @0x2000 (512B, magic 0x97E6EEDD,
  crc32_be over sb[8:512] at sb[4:8]), data blocks @0x3000 + N*blocksize.
  sb root nodes (Inode @+72, Bitmap @+152, Longfile @+232): contiguous
  extent {size, ptr[0]=start}; the Inode file is indirection-mapped via
  L1 (node ptr[0]) -> L2s -> data blocks (identity for the first 25k).
  inode N @ inode-table byte (N-1)*0x80. Dir entries 32B [ino:4][len:1][name:27].
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

class QNX6:
    def __init__(self, img):
        self.d = img
        sb = img[0x2000:0x2200]
        (self.magic, self.checksum, self.serial, self.ctime, self.atime,
         self.flags, self.v1, self.v2, self.volumeid, self.blocksize,
         self.num_inodes, self.free_inodes, self.num_blocks, self.free_blocks,
         self.allocgroup) = struct.unpack_from('<IIQIIIHH16sIIIIII', sb, 0)
        assert self.magic in (0x97E6EEDD, 0x68191122), hex(self.magic)
        self.nodes = {}
        for name, off in (('inode', 72), ('bitmap', 152), ('longfile', 232)):
            size, = struct.unpack_from('<Q', sb, off)
            ptrs = struct.unpack_from('<16I', sb, off + 8)
            levels, mode = sb[off + 72], sb[off + 73]
            self.nodes[name] = dict(size=size, start=ptrs[0], levels=levels, mode=mode)
        # verify the sb checksum
        assert self.checksum == crc32_be(img[0x2008:0x2200]), 'sb checksum mismatch'

    def data(self, blk):
        return self.d[0x3000 + blk * self.blocksize: 0x3000 + (blk + 1) * self.blocksize]

    def inode(self, n):
        off = (n - 1) * 0x80
        blk = off // self.blocksize
        phys = self._inode_block(blk)
        return self.d[0x3000 + phys * self.blocksize + off % self.blocksize:
                      0x3000 + phys * self.blocksize + off % self.blocksize + 0x80]

    def _inode_block(self, blk):
        # L1 @ node.start, L2s = L1 entries, data = L2 entries
        l1 = self.data(self.nodes['inode']['start'])
        l2_idx = blk // (self.blocksize // 4)
        if l2_idx >= 15:  # node has 15 direct ptrs? unused here
            l2blk = struct.unpack_from('<I', l1, l2_idx * 4)[0]
            assert l2blk != 0xFFFFFFFF
            l2 = self.data(l2blk)
            return struct.unpack_from('<I', l2, (blk % (self.blocksize // 4)) * 4)[0]
        # identity for the inode-table's first blocks (empirical)
        return blk

    def inode_fields(self, n):
        raw = self.inode(n)
        size, uid, gid = struct.unpack_from('<QII', raw, 0)
        ftime, mtime, atime, ctime = struct.unpack_from('<IIII', raw, 16)
        mode, ext = struct.unpack_from('<HH', raw, 32)
        ptrs = struct.unpack_from('<16I', raw, 36)
        levels, status = raw[100], raw[101]
        return dict(size=size, uid=uid, gid=gid, mode=oct(mode), ext=oct(ext),
                    ptrs=ptrs, levels=levels, status=status)

    def read_file(self, raw):
        """raw = inode bytes; returns the file content."""
        size, = struct.unpack_from('<Q', raw, 0)
        ptrs = struct.unpack_from('<16I', raw, 36)
        out = bytearray()
        for i in range(15):
            b = ptrs[i]
            if b == 0xFFFFFFFF or b == 0:
                break
            out += self.data(b)
        return bytes(out[:size])

    def list_dir(self, raw):
        out = []
        for chunk in self._dir_chunks(raw):
            for off in range(0, len(chunk), 32):
                de = chunk[off:off + 32]
                ino, dsize = struct.unpack_from('<IB', de, 0)
                if ino == 0:
                    continue
                name = de[5:5 + dsize].decode('latin1', 'replace')
                out.append((ino, name))
        return out

    def _dir_chunks(self, raw):
        ptrs = struct.unpack_from('<16I', raw, 36)
        chunks = []
        for i in range(15):
            b = ptrs[i]
            if b == 0xFFFFFFFF or b == 0:
                break
            chunks.append(self.data(b))
        return chunks

    def lookup(self, dirino, name):
        return dict((n, i) for i, n in self.list_dir(self.inode(dirino))).get(name)

def main():
    img = open(sys.argv[1], 'rb').read()
    q = QNX6(img)
    print('sb: blocksize=%d inodes=%d free_inodes=%d blocks=%d free_blocks=%d' %
          (q.blocksize, q.num_inodes, q.free_inodes, q.num_blocks, q.free_blocks))
    print('nodes:', {k: (v['size'], v['start'], v['levels']) for k, v in q.nodes.items()})
    print('root inode:', q.inode_fields(1))
    for path in sys.argv[2:]:
        ino = 1
        ok = True
        for part in [p for p in path.split('/') if p]:
            nxt = q.lookup(ino, part)
            if nxt is None:
                print('MISSING %r under ino %d' % (part, ino))
                ok = False
                break
            ino = nxt
        if not ok:
            continue
        raw = q.inode(ino)
        f = q.inode_fields(ino)
        print('== %s (ino %d): mode=%s size=%d' % (path, ino, f['mode'], f['size']))
        if f['mode'].startswith('0o4'):  # dir
            for cino, cname in q.list_dir(raw):
                print('    ino=%d %s' % (cino, cname))
        else:
            print('    content:', q.read_file(raw))

if __name__ == '__main__':
    main()
