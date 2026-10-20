#!/bin/sh
# A7 recon: find out what the BB10 Navigator is compositing, and under which
# window-group name, so a devuser process can try to JOIN that group instead
# of creating its own (which A4 did, and which the Navigator never draws).
#
# Runs ON the device as devuser, no build. Drive it over the existing channel:
#   python3 runtime/qnx-shims/qconn_exec.py push runtime/qnx-shims/nav_recon.sh /accounts/devuser/nav_recon.sh
#   python3 runtime/qnx-shims/qconn_exec.py "sh /accounts/devuser/nav_recon.sh"
# or over SSH:  runtime/art-qnx/device/q20ssh 'sh -s' < runtime/qnx-shims/nav_recon.sh
#
# The device shell is minimal (no head, no printf). POSIX sh + cat/ls/for only.

say() { echo "=== $1"; }
dump() {           # dump <path>: cat it if readable, else say why
  if [ -r "$1" ]; then
    echo "--- $1"
    cat "$1" 2>&1
    echo
  else
    echo "--- $1 : not readable"
  fi
}
dumpdir() {        # dumpdir <dir>: list it, then cat each entry
  if [ -d "$1" ]; then
    echo "--- ls $1"
    ls -la "$1" 2>&1
    for f in "$1"/*; do
      [ -f "$f" ] && dump "$f"
    done
  else
    echo "--- $1 : absent"
  fi
}

say "who am i"
id 2>&1
echo "HOME=$HOME"

say "this process's screen/window environment (a bare process should have none)"
# If the Navigator launched us it would set a window-group name here. A qconn
# or SSH shell should show nothing: that absence is the point.
env 2>&1 | grep -i -E "WINDOW|SCREEN|GROUP|NAVIGATOR|BB_|_CARD|GL" || echo "(no windowing env, as expected for a non-launched process)"

say "Navigator PPS (the live window-group registry)"
dumpdir /pps/services/navigator
dump    /pps/services/navigator/control
dump    /pps/services/navigator/state
dump    /pps/services/navigator/windowgroup

say "window manager / screen PPS"
dumpdir /pps/services/window_manager
dumpdir /pps/system/navigator
dumpdir /pps/services/screen

say "who is in the foreground (look for a grp:/window-group token)"
# NOT control?wait: opening a PPS object with ?wait blocks until the next
# change, which never comes on a locked idle device, and the whole recon hangs.
# The foreground app is in state (curr_window) and in its own rundata window_id.
dump /pps/services/navigator/state
dump /pps/system/navigator/applications/applications

say "running graphics processes (navigator, screen service, winmgr)"
# pidin is usually present on QNX; fall back to ls /proc if not.
( pidin -F "%a %n %p" 2>/dev/null | grep -i -E "navigat|screen|winmgr|wm" ) \
  || ( ls /proc 2>&1 )

say "libscreen the probe links against"
ls -la /base/usr/lib/libscreen.so 2>&1
ls -la /usr/lib/libscreen.so 2>&1

say "done"
