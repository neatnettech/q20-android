#!/usr/bin/env python3
"""Turn off the navigator's first-launch autorun in a BB10 user-partition image.

The setup wizard (OOBE) is started by the navigator, not by the firstlaunch PPS
object: /var/pps/system/navigator/config carries

    autorun::1
    autorun_app::sys.firstlaunch.gYABgE1L_lY.sjW85E1SCBQsrco

and the navigator launches autorun_app at every boot while autorun is 1. The
Classic's working no-wizard bake has autorun::0 plus the four tutorials_*_done
keys (so the post-setup tutorial overlays stay off); its stock Q10 counterpart
has autorun::1 and no tutorials keys, and that single byte - not the
/var/pps/services/firstlaunch/status_public flag that qnx6_wizskip.py injects -
is what made the 2026-11-01 P'9983 flash boot into the wizard anyway.

Patch is in place in the data block: the content stays inside one 4K block, so
only the file bytes and the inode size field change. No bitmap, no free counts,
no sb checksum (that covers sb[8:512] only).

usage: qnx6_navautorun.py <ufs.bin> [out.bin]
"""
import os, shutil, struct, sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from qnx6_inspect import QNX6

CFG = '/var/pps/system/navigator/config'
# the Classic bake's post-setup tutorial state, appended in PPS key order
TUTORIALS = (b'tutorials_app_launch_homeswipe_done:n:1\n'
             b'tutorials_done_binary_code:n:63\n'
             b'tutorials_failed_homeswipe_done:n:1\n'
             b'tutorials_setup_assistance_done:n:1\n')


def resolve(q, path):
    ino = 1
    for part in [p for p in path.split('/') if p]:
        nxt = q.lookup(ino, part)
        assert nxt is not None, 'missing %r in %s' % (part, path)
        ino = nxt
    return ino


def patch(path):
    q = QNX6(open(path, 'rb').read())
    ino = resolve(q, CFG)
    raw = q.inode(ino)
    old = q.read_file(raw)
    blk = struct.unpack_from('<I', raw, 36)[0]

    new = old.replace(b'\nautorun::1\n', b'\nautorun::0\n', 1)
    assert new != old or b'\nautorun::0\n' in old, 'no autorun key in %s' % CFG
    if b'tutorials_' not in new:
        new += TUTORIALS
    assert len(new) <= q.blocksize, 'content would spill to a second block'
    if new == old:
        print('already patched, nothing to do')
        return ino, new

    # the file bytes (one block, zero-padded) and the inode size field
    base = 0x3000 + blk * q.blocksize
    with open(path, 'r+b') as f:
        f.seek(base)
        f.write(new + b'\0' * (q.blocksize - len(new)))
        off = (ino - 1) * 0x80
        f.seek(0x3000 + q._inode_block(off // q.blocksize) * q.blocksize + off % q.blocksize)
        f.write(struct.pack('<Q', len(new)))
    return ino, new


def main():
    src = sys.argv[1]
    dst = sys.argv[2] if len(sys.argv) > 2 else src
    if dst != src:
        print('copying %s -> %s' % (src, dst))
        shutil.copyfile(src, dst)
    ino, want = patch(dst)

    # re-read through the reader: the fix is only real if the fs agrees
    q = QNX6(open(dst, 'rb').read())
    got = q.read_file(q.inode(resolve(q, CFG)))
    assert got == want, 'readback mismatch'
    assert b'\nautorun::0\n' in got and b'tutorials_setup_assistance_done' in got
    print('%s (ino %d): %d bytes, autorun::0, tutorials seeded' % (CFG, ino, len(got)))


if __name__ == '__main__':
    main()
