# tools/bb10mt - vendored BB10 MultiTool

From [bb10root/bb10mt](https://github.com/bb10root/bb10mt) (GPL-3.0),
prebuilt `bb10mt_aarch64_darwin` (arm64 macOS) + libusb + the loader map.
Kept for two jobs:

1. **`autoloader loaders -i <autoloader.exe> -o <dir>`** - extract the
   213-entry RAM-loader table from a cap.exe autoloader (how the P'9983's
   loader set was obtained; see devices/p9983).
2. **`qnx6 fsck -i <image>`** - verify patched QNX6 user-partition images
   (used for the pre-rooted P'9983 image in devices/p9983).

Usage: `DYLD_LIBRARY_PATH=$PWD ./bb10mt_aarch64_darwin <cmd>` from this
directory (the bundled libusb is arm64).
