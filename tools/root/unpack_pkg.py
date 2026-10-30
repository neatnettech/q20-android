import zipfile, os, shutil, sys
# unpack a bar into a /var/android subdir (runs on the device via g_upd)
src, dst = sys.argv[1], sys.argv[2]
if os.path.exists(dst):
    shutil.rmtree(dst)
os.makedirs(dst)
zipfile.ZipFile(src).extractall(dst)
print("UNPACKED", os.listdir(dst))
