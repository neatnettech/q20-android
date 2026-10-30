#!/usr/bin/env python3
"""Build the winning device-configuration package: mounts the qnx6 image
(built by qnx6symlink.py) over /base/scripts.

usage: makepkg.py <out.bar> <links.txt> <image.qnx6>
The links file is the assets/links content (e.g.
"version:1\\nmount:assets/data/<image>:/base/scripts:qnx6\\n").
"""
import zipfile, hashlib, base64, random, os, sys

def rid(prefix):
    return prefix + ''.join(random.choice(
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_')
        for _ in range(22))

def main():
    out, linksf, imgf = sys.argv[1], sys.argv[2], sys.argv[3]
    links = open(linksf, 'rb').read()
    img = open(imgf, 'rb').read()
    imgname = os.path.basename(imgf)
    perms = ("assets/data/%s:0:0:666\nassets/data:0:0:777\n"
             "assets:0:0:777\n.:0:0:777\n" % imgname).encode()

    def dig(b):
        return base64.b64encode(hashlib.sha512(b).digest()).decode()

    assets = [('links', links), ('perms', perms), ('data/' + imgname, img)]
    ae = ''.join("\nArchive-Asset-Name: /assets/%s\nArchive-Asset-SHA-512-Digest: %s\n"
                 % (n, dig(b)) for n, b in assets)
    mf = """Archive-Manifest-Version: 1.5
Archive-Created-By: q20

Package-Type: device-configuration
Package-Author: Q20
Package-Author-Id: %s
Package-Name: q20root
Package-Id: %s
Package-Version: 1.0.0.0
Package-Version-Id: %s
Package-Architecture: armle-v7

System-Data-Type: os_data
System-Data-Requires-System: os/10.0.0.8
System-Data-Persistence: permanent
Device-Configuration-Type: root
%s
""" % (rid('andrA'), rid('andrB'), rid('andrC'), ae)
    with zipfile.ZipFile(out, 'w', zipfile.ZIP_DEFLATED) as z:
        z.writestr('META-INF/MANIFEST.MF', mf)
        for n, b in assets:
            z.writestr('assets/' + n, b)
    print("wrote", out, os.path.getsize(out))

if __name__ == '__main__':
    main()
