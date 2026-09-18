# q20-android

Android 6.0 on the BlackBerry Classic (Q20), which runs QNX.

## Status

✅ Docker build environment (q20-aosp6:trusty)
✅ Android 6.0.1 source downloaded (gitignored, local only)
✅ Q20 runtime specimens and upstream research cloned (gitignored, local only)
✅ Android 4.3 vs 6.0 runtime comparison (docs/runtime-comparison.md)
❌ Q20 device connected
❌ Q20 runtime extracted
❌ ART running on QNX

## Structure

* `art/` `bionic/` `libcore/` `frameworks/` `system/` AOSP 6.0.1 source
  snapshots (gitignored, downloaded, not committed)
* `Blackberry-Research/` upstream research reference (gitignored), see
  credits below
* `docs/` notes, specs, and findings
* `runtime/` ART, libcore, and dynamic linker (work area)
* `framework/` Android framework pieces (work area)
* `tests/` integration and unit tests
* `docker-compose.yml` Docker environment for AOSP build

## Credits

Reverse engineering research on BB10/QNX and the factory Android runtime
comes from stanw47's Blackberry-Research:
https://github.com/stanw47/Blackberry-Research

The extracted Q20 runtime specimens, binder on QNX port, graft layer, and
session notes used by our analysis live in that repo (cloned locally as
`Blackberry-Research/`, not committed here).
