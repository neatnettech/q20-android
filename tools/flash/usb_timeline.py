#!/usr/bin/env python3
"""Log 0fca USB PID transitions with timestamps - the boot reference tool.

Run it while a device boots (or hangs): the PID sequence is the boot
timeline. Reference map (from the Classic and the P'9983 work):

  0fca:0001  bootrom handshake window (flash lane entry)
  0fca:8001  RAM-loader / resident-loader state
  0fca:8017  OS session up (the OS is alive in userland)
  (absent)   OS up with USB off (charging only) or power-cycled

Use: compare the P'9983's timeline against the Classic's to see where
the boot stalls. Non-invasive: never claims the interface, just watches.

usage: usb_timeline.py [--timeout SECONDS]
"""
import sys, time
import usb.core

t0 = time.time()
last = None

def state():
    d = usb.core.find(idVendor=0x0FCA)
    return d.idProduct if d else None

def log(s):
    print('%8.1fs  %s' % (time.time() - t0, s), flush=True)

log('watching 0fca... (ctrl-c to stop)')
timeout = float(sys.argv[sys.argv.index('--timeout') + 1]) if '--timeout' in sys.argv else 0
while True:
    s = state()
    if s != last:
        log(('%04X' % s) if s else '(off the bus)')
        last = s
    if timeout and time.time() - t0 > timeout:
        log('timeout')
        break
    time.sleep(0.1)
