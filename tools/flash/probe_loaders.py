#!/usr/bin/env python3
"""Probe candidate RAM-loaders against a device (e.g. the P'9983, hwid
8F00270A - see research/p9983/).

usage: probe_loaders.py <loaders-dir> [password]

For every loader_*.bin file: bootrom bring-up -> upload -> run -> reopen
8001 -> SetMode(2). The first loader that answers SetMode(2) wins (appends
to loaders.ini). Between attempts it sends channel0(3) Reboot to the loader
to return the device to the bootrom (bb10mt's loop trick); if the device
drops off the bus it waits for a fresh 0001 (physical ritual).

Needs a loader candidate set: bb10mt (`bb10root/bb10mt` on GitHub) can
extract the full set from an autoloader:
    bb10mt autoloader loaders -i <autoloader.exe> -o <dir>
"""
import os, sys, time, glob
import usb.core

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import bblink
from bblink import BBSession, load_loader, PID_BOOTROM, PID_RAMLOADER

LOADER_DIR = sys.argv[1] if len(sys.argv) > 1 else 'loaders'
PW = sys.argv[2] if len(sys.argv) > 2 else os.environ['Q20_PW']

def have(pid):
    return usb.core.find(idVendor=0x0FCA, idProduct=pid) is not None

def wait_bootrom(timeout=180):
    t0 = time.time()
    print('  waiting for fresh 0001 (ritual: unplug, power off, plug)...', flush=True)
    while time.time() - t0 < timeout:
        if have(PID_BOOTROM):
            return True
        time.sleep(0.05)
    return False

def try_loader(path):
    s = BBSession(verbose=False)
    model_id = None
    try:
        if not s._open_pid(PID_BOOTROM, timeout=15000):
            return 'no-bootrom'
        # a half-open session wedges the bootrom: clear with Reboot + reconnect
        for _ in range(3):
            try:
                s.channel0(3, b'')          # Reboot cmd
            except Exception:
                pass
            time.sleep(1.5)
            try:
                s.close()
            except Exception:
                pass
            if s._open_pid(PID_BOOTROM, timeout=10000):
                break
        s.ping0()
        rom = s.get_var(2, 2000)
        if len(rom) >= 20:
            model_id = bblink.u32(rom[16:20])
        print('    model %08X' % model_id, flush=True)
        if not s.set_mode(1):
            return 'setmode1-fail'
        if not s.password_info(PW.encode()):
            return 'password-fail'
        s.switch_channel()
        s.get_metrics()
        ldr, addr = load_loader(path, model_id)
        print('    uploading %d bytes -> %#x' % (len(ldr), addr), flush=True)
        s.send_loader(addr, ldr)
        s.run_loader(addr)
        time.sleep(1.2)
        s.close()
        if not s._open_pid(PID_RAMLOADER, timeout=30000):
            return 'loader-no-enum'
        print('    loader enumerated, trying SetMode(2)...', flush=True)
        ok = s.set_mode(2)
        if ok:
            s.password_info(b'')
            return 'SETMODE-OK'
        return 'setmode2-timeout'
    except Exception as e:
        return 'err:' + str(e)[:60]
    finally:
        try:
            s.channel0(3, b'')          # Reboot -> back to bootrom
        except Exception:
            pass
        try:
            s.close()
        except Exception:
            pass

def main():
    files = sorted(glob.glob(os.path.join(LOADER_DIR, 'loader_*.bin')))
    print('probing %d loaders' % len(files), flush=True)
    results = []
    for f in files:
        name = os.path.basename(f)
        print('== %s' % name, flush=True)
        for attempt in range(3):
            if not have(PID_BOOTROM):
                # try the Reboot trick via the loader first
                s2 = BBSession(verbose=False)
                try:
                    if s2._open_pid(PID_RAMLOADER, timeout=3000):
                        s2.channel0(3, b'')
                        time.sleep(2)
                except Exception:
                    pass
                s2.close()
                if not have(PID_BOOTROM) and not wait_bootrom():
                    print('  no bootrom after 180s - keep waiting (device may be charging); ritual: unplug, power off, plug', flush=True)
                    while not wait_bootrom(300):
                        print('  still waiting for fresh 0001...', flush=True)
            r = try_loader(f)
            print('  %s -> %s' % (name, r), flush=True)
            if r == 'SETMODE-OK':
                with open('loaders.ini', 'a') as out:
                    out.write('[%s]\n%s=true\n[%s]\n%s=true\n' % (
                        name, 'MODEL', 'MODEL', name))
                print('WINNER: %s (SetMode(2) answered)' % name, flush=True)
                return
            if r in ('password-fail', 'setmode1-fail', 'no-bootrom'):
                time.sleep(2)
                continue
            break
        results.append((name, r))
    print('all failed:', results, flush=True)
    sys.exit(2)

if __name__ == '__main__':
    main()
