#!/usr/bin/env python3
"""Unpack an mfcq container (os.signed) into its streams.

Inverse of qcfm_pack.py: walks the pfcq/rrcq records and extracts each
stream's block payload. Names by stream type: rcfs (0x09), sig2 (0x89),
mbr (0x06), ufs (0x05).

usage: qcfm_unpack_streams.py os.signed [outdir]
"""
import struct, os, sys

TNAMES = {0x05: 'ufs', 0x06: 'mbr', 0x07: 'sig', 0x08: 'ifs',
          0x09: 'rcfs', 0x18: 'os', 0x89: 'sig2'}

def main():
    path, outdir = sys.argv[1], sys.argv[2] if len(sys.argv) > 2 else '.'
    os.makedirs(outdir, exist_ok=True)
    f = open(path, 'rb')
    if f.read(4) != b'mfcq':
        sys.exit('not an mfcq container')
    f.seek(0x30)
    nfiles = struct.unpack('<I', f.read(4))[0]
    f.seek(0x34)
    hdrsz = struct.unpack('<I', f.read(4))[0]
    f.seek(0x3c)
    recs = []
    for i in range(nfiles):
        tag = f.read(4)
        if tag != b'pfcq':
            sys.exit('expected pfcq at rec %d, got %r' % (i, tag))
        d = f.read(0x28)
        typ = struct.unpack_from('<I', d, 8)[0]
        rtag = f.read(4)
        if rtag != b'rrcq':
            sys.exit('expected rrcq at rec %d, got %r' % (i, rtag))
        rd = f.read(0xc)
        blocks = struct.unpack('<III', rd)[2]
        recs.append((typ, blocks))
    f.seek(hdrsz + 0x20)
    for i, (typ, blocks) in enumerate(recs):
        name = os.path.join(outdir, '%d-%s.bin' % (i, TNAMES.get(typ, '%02x' % typ)))
        with open(name, 'wb') as out:
            for b in range(blocks):
                out.write(f.read(0x10000))
        print('%s  %d bytes' % (name, blocks * 0x10000))

if __name__ == '__main__':
    main()
