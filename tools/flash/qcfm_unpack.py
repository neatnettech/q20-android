#!/usr/bin/env python3
"""Extract streams from an mfcq/.signed container (inverse of qcfm_pack).

usage: qcfm_unpack.py <container> [outdir]
Prints the stream table and writes each stream as <outdir>/stream<i>.type<t>.bin
(padded to 0x10000 blocks, exactly as the loader writes them).
"""
import os, struct, sys

BLOCK = 0x10000

def u32(b, o):
    return struct.unpack_from('<I', b, o)[0]

def main():
    path = sys.argv[1]
    outdir = sys.argv[2] if len(sys.argv) > 2 else '.'
    d = open(path, 'rb')
    head = d.read(0x400)
    if head[0:4] != b'mfcq':
        sys.exit("not mfcq")
    # mhf2 at 0x20: magic, cksum, version, hdrlen, nfiles, headersz@+0x14
    nfiles = u32(head, 0x30)
    headersz = u32(head, 0x34)
    data_start = headersz + 0x20
    print("nfiles=%d headersz=%#x data_start=%#x" % (nfiles, headersz, data_start))
    off = 0x3C  # first cf2 record
    streams = []
    for i in range(nfiles):
        d.seek(off)
        cf2 = d.read(0x2C)
        if cf2[0:4] != b'pfcq':
            sys.exit("bad pfcq at %#x" % off)
        t = u32(cf2, 0x0C)
        rrec = d.read(0x10)
        if rrec[0:4] != b'rrcq':
            sys.exit("bad rrcq at %#x" % (off + 0x2C))
        count = u32(rrec, 0x0C)
        streams.append((t, count))
        off += 0x2C + 0x10
    pos = data_start
    for i, (t, count) in enumerate(streams):
        size = count * BLOCK
        name = os.path.join(outdir, "stream%d.type%02x.bin" % (i, t))
        with open(name, 'wb') as f:
            d.seek(pos)
            left = size
            while left > 0:
                chunk = d.read(min(1 << 20, left))
                if not chunk:
                    sys.exit("short container")
                f.write(chunk)
                left -= len(chunk)
        print("stream%d type=%#04x blocks=%d (%d bytes) -> %s" % (i, t, count, size, name))
        pos += size
    print("container end %#x, file size %d" % (pos, os.path.getsize(path)))

if __name__ == '__main__':
    main()
