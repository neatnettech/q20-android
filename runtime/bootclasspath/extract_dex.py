#!/usr/bin/env python3
"""Extract embedded dex files from an Android 6.0.1 boot.oat (speed-profile layout)."""
import struct
import sys
import os

path = sys.argv[1]
outdir = sys.argv[2] if len(sys.argv) > 2 else "."
data = open(path, "rb").read()

# Marshmallow wraps the oat in an ELF; find the oat magic and use it as base
base = data.find(b"oat\n")
assert base >= 0, "not an oat file"
if base > 0:
    print(f"oat base offset: 0x{base:x} (ELF-wrapped)")
version = data[base+4:base+8]
print(f"oat version: {version!r}")

pos = base + 8
checksum = struct.unpack_from("<I", data, pos)[0]; pos += 4
isa, features, dex_count = struct.unpack_from("<III", data, pos); pos += 12
offsets = struct.unpack_from("<8I", data, pos); pos += 32
delta = struct.unpack_from("<i", data, pos)[0]; pos += 4
img_checksum, img_begin = struct.unpack_from("<II", data, pos); pos += 8
kv_size = struct.unpack_from("<I", data, pos)[0]; pos += 4
pos += kv_size
print(f"dex files: {dex_count}, kv store: {kv_size}B")

for i in range(dex_count):
    loc_size = struct.unpack_from("<I", data, pos)[0]; pos += 4
    loc = data[pos:pos+loc_size].decode("utf-8", "replace"); pos += loc_size
    dex_checksum = struct.unpack_from("<I", data, pos)[0]; pos += 4
    dex_offset = struct.unpack_from("<I", data, pos)[0]; pos += 4
    if dex_offset == 0:
        print(f"  {i}: {loc}: NO DEX (offset 0, image-only)")
        continue
    dex_offset += base  # offsets are relative to the oat base
    assert data[dex_offset:dex_offset+4] == b"dex\n", f"bad dex magic at {dex_offset}"
    file_size = struct.unpack_from("<I", data, dex_offset + 32)[0]
    class_defs = struct.unpack_from("<I", data, dex_offset + 96)[0]
    pos += class_defs * 4  # class offsets table follows each dex entry
    dex = data[dex_offset:dex_offset+file_size]
    # dex2oat embeds the dex with a stale header: recompute the SHA-1
    # signature (over bytes 32..file_size) then the adler32 checksum
    # (over bytes 12..file_size, which includes the signature).
    import zlib, hashlib
    dex = bytearray(dex)
    dex[12:32] = hashlib.sha1(dex[32:file_size]).digest()
    struct.pack_into("<I", dex, 8,
                     zlib.adler32(bytes(dex[12:file_size])) & 0xffffffff)
    dex = bytes(dex)
    fname = os.path.basename(loc.rstrip("/")).replace(".jar", ".dex")
    out = os.path.join(outdir, fname)
    with open(out, "wb") as f:
        f.write(dex)
    print(f"  {i}: {loc} -> {fname} ({file_size}B)")
print("done")
