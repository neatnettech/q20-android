# q20-android

Android 6.0 on the BlackBerry Classic (Q20), which runs QNX.

## Status

| Item | State |
|---|---|
| Docker build environment (q20-aosp6:trusty) | done |
| Android 6.0.1 source downloaded (gitignored, local only) | done |
| Q20 runtime specimens and upstream research cloned (gitignored, local only) | done |
| Full Q20 Android 4.3 runtime extracted from signed BARs (gitignored, local only) | done |
| Android 4.3 vs 6.0 runtime comparison (docs/runtime-comparison.md) | done |
| Q20 device connected | pending |
| Q20 runtime extracted | pending |
| ART running on QNX | pending |

## Structure

* `art/` `bionic/` `libcore/` `frameworks/` `system/` AOSP 6.0.1 source
  snapshots (gitignored, downloaded, not committed)
* `Blackberry-Research/` upstream research reference (gitignored), see
  credits below
* `q20-runtime/` complete factory Android 4.3 runtime unpacked from the
  signed `sys.android` and `sys.android.shell` BARs for OS 10.3.3.3216
  (gitignored), see credits below
* `docs/` notes, specs, and findings
* `runtime/` ART, libcore, and dynamic linker (work area)
* `framework/` Android framework pieces (work area)
* `tests/` integration and unit tests
* `docker-compose.yml` Docker environment for AOSP build

## Credits

* Reverse engineering research on BB10/QNX and the factory Android runtime
  comes from stanw47's Blackberry-Research:
  https://github.com/stanw47/Blackberry-Research
  The extracted Q20 runtime specimens, binder on QNX port, graft layer, and
  session notes used by our analysis live in that repo (cloned locally as
  `Blackberry-Research/`, not committed here).
* The full Android runtime BARs (`sys.android-10.3.3.213`,
  `sys.android.shell-10.3.3.213`) come from ProjectBerry's BB10-Resources
  release "Fix/Update Android Runtime":
  https://github.com/ProjectBerry/BB10-Resources/releases/tag/runtime_v_update
  Extracted locally into `q20-runtime/` (not committed here).
