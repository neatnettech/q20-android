#!/usr/bin/env python3
"""Extract the signed mfcq containers from a BB10 cap.exe autoloader.

Handles both observed header variants (the Classic's ver2 header right at
cap_end, and the Q10/10.3.3.498 builds with a 0x3C-byte prefix table before
the ver2 sig) and names the containers by their first stream type:
ifs.signed (0x08), radio.signed (0x0c), os.signed (0x09/0x05).

usage: extract_autoloader.py <autoloader.exe> [outdir]
"""
import struct, os, sys

TNAMES = {5: 'os', 6: 'os', 8: 'ifs', 9: 'os', 0x89: 'os', 0x0c: 'radio',
          0x8c: 'radio', 0x0a: 'radio'}

def pe_end(f):
    f.seek(0x3c); pe = struct.unpack('<I', f.read(4))[0]
    f.seek(pe + 6); n = struct.unpack('<H', f.read(2))[0]
    f.seek(pe + 20); osz = struct.unpack('<H', f.read(2))[0]
    base = pe + 24 + osz
    end = 0
    for i in range(n):
        f.seek(base + i * 40 + 20); so = struct.unpack('<I', f.read(4))[0]
        f.seek(base + i * 40 + 16); sr = struct.unpack('<I', f.read(4))[0]
        end = max(end, so + sr)
    return end

def main():
    path, outdir = sys.argv[1], sys.argv[2] if len(sys.argv) > 2 else '.'
    os.makedirs(outdir, exist_ok=True)
    sz = os.path.getsize(path)
    f = open(path, 'rb')
    cap = pe_end(f)
    # find the ver2 sig; builds prefix it with a variable length name table
    # (SQN100 10.3.2.159 0x30, SQK100 10.3.2.159 0x34, 10.3.3.498 builds 0x3C)
    f.seek(cap)
    i = f.read(0x100).find(b'\x9c\xd5\xc5\x97' * 3)
    hdr_off = cap + i if i >= 0 else None
    if hdr_off is None:
        sys.exit('no ver2 header after cap_end %#x' % cap)
    f.seek(hdr_off + 12 + 80)
    nfiles = struct.unpack('<I', f.read(4))[0]
    f.read(4)
    offs = [struct.unpack('<Q', f.read(8))[0] for _ in range(nfiles)]
    for i, off in enumerate(offs):
        nxt = offs[i + 1] if i + 1 < nfiles else sz
        f.seek(off)
        if f.read(4) != b'mfcq':
            print('file%d @%#x: not mfcq, skipping' % (i, off))
            continue
        # first stream type decides the name
        f.seek(off + 0x3c + 0x2c)
        rrcq = f.read(0x10)
        assert rrcq[0:4] == b'rrcq', 'bad rrcq at %#x' % (off + 0x68)
        typ = struct.unpack('<I', f.read(4))[0] if False else None
        f.seek(off + 0x3c + 0x0c)
        typ = struct.unpack('<I', f.read(4))[0]
        name = os.path.join(outdir, TNAMES.get(typ, 'stream') + '.signed')
        data = bytearray()
        f.seek(off)
        while len(data) < nxt - off:
            chunk = f.read(min(1 << 20, nxt - off - len(data)))
            if not chunk:
                sys.exit('short read on file%d' % i)
            data += chunk
        open(name, 'wb').write(data)
        print('%s  %d bytes  (first stream type 0x%02x)' % (name, len(data), typ))

if __name__ == '__main__':
    main()
