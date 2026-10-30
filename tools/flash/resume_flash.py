#!/usr/bin/env python3 -u
"""Resume flash on the already-uploaded loader (PID 8001) after an interrupted
attempt. Verifies channel2 framing integrity (get_mct round-trip) before
committing to the stream. Exits 1 if the loader is dead -> needs the ritual."""
import sys, time, types
sys.path.insert(0, '/Users/piotrpestka/github/q20-android/Blackberry-Research/tools')
import bblink

s = bblink.BBSession(verbose=True)
# wait for the loader to finish its device-side erase and service USB again
alive = False
for i in range(30):   # up to ~10 min
    if s._open_pid(0x8001, timeout=3000):
        try:
            r = s.get_mct()
            if len(r) > 100:
                print("loader alive, MCT %d bytes, framing clean" % len(r), flush=True)
                alive = True
                break
            print("[%d] short MCT answer (%d bytes), suspicious" % (i, len(r)), flush=True)
        except Exception as e:
            print("[%d] not ready (%s)" % (i, type(e).__name__), flush=True)
        s.close()
    else:
        print("[%d] no 8001" % i, flush=True)
    time.sleep(20)
if not alive:
    print("NEEDS-RITUAL", flush=True)
    sys.exit(1)

opts = types.SimpleNamespace(verbose=True, attached=True,
                             family='15',
                             files=[__import__('os').path.expanduser('~/q20-flash/OS.signed.unsigned'),
                                    __import__('os').path.expanduser('~/q20-flash/radio.signed')])
try:
    bblink.cmd_flash(s, opts)
    print("FLASH-OK", flush=True)
except Exception as e:
    print("FLASH-FAILED: %s: %s" % (type(e).__name__, e), flush=True)
    sys.exit(1)
finally:
    s.close()
