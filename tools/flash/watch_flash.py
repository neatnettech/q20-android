#!/usr/bin/env python3
"""Tight bootrom edge-watcher: polls for 0fca:0001 every 0.05s and, the
instant it appears, hands off to bblink flash. Solves the missed-edge
problem when the device's 0001 window is shorter than shell-poll
granularity (e.g. the P'9983 power-cycling on USB-only power).

usage: watch_flash.py [files...]   (defaults: Classic OS+radio)
"""
import subprocess, sys, time, os
import usb.core

HERE = os.path.dirname(os.path.abspath(__file__))
FILES = sys.argv[1:] or [
    os.path.expanduser('~/q20-flash/OS.signed.unsigned'),
    os.path.expanduser('~/q20-flash/radio.signed'),
]
LOADER = os.path.join(HERE, 'loader_9600270A-00.bin')

def state():
    d = usb.core.find(idVendor=0x0FCA)
    return d.idProduct if d else None

print('watcher: unplug the device, power it fully off, then plug in (touch nothing)', flush=True)
print('waiting for the device to leave the bus...', flush=True)
while state() is not None:
    time.sleep(0.05)
print('off the bus - now waiting for fresh 0001 (plug in now)', flush=True)
t0 = time.time()
while True:
    s = state()
    if s == 0x0001:
        print('FRESH 0001 at +%.1fs - launching flash' % (time.time() - t0), flush=True)
        break
    if s == 0x8001:
        print('saw 8001 (missed the window) - unplug, power off, plug again', flush=True)
        while state() is not None:
            time.sleep(0.05)
        print('off the bus again - plug in', flush=True)
    time.sleep(0.05)

r = subprocess.run([sys.executable, '-u', os.path.join(HERE, 'bblink.py'),
                    '--loader', LOADER, '--password', os.environ['Q20_PW'],
                    'flash', *FILES])
sys.exit(r.returncode)
