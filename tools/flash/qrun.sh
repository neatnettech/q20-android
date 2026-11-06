#!/bin/sh
# qrun.sh <helper|-> <local-cmdfile>  - run a command file on the Q20 via a /q helper
# helper: e.g. u_apps, g_Disk_Drivers, u_upd, or '-' for plain devuser ssh
set -e
H="$1"; F="$2"
D=/Users/piotrpestka/github/q20-android/runtime/qnx-shims/door
sh "$D/connect.sh" "${Q20_IP:-192.168.1.184}" "${Q20_PW:?set Q20_PW}" --push "$F" /accounts/devuser/.q20cmd >/dev/null 2>&1
if [ "$H" = "-" ]; then
  Q20_IP="${Q20_IP:-192.168.1.184}" sh "$D/../../art-qnx/device/q20ssh" 'sh /accounts/devuser/.q20cmd 2>&1'
else
  Q20_IP="${Q20_IP:-192.168.1.184}" sh "$D/../../art-qnx/device/q20ssh" "echo 'sh /accounts/devuser/.q20cmd' | /q/$H"
fi 2>&1 | grep -v "set for all\|^uid\|^Was\|^Back\|ssh attempt\|platform independent\|PYTHONHOME"
