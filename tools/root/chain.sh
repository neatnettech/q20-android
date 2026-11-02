#!/bin/sh
# q20 root chain: post-UFS-flash, first boot (the /q helpers must be up).
# Builds everything locally, then: stages the payload into the trusted
# Android-subsystem carriers, installs the shadow+symlink deviceconfig
# package via the installer queue, fires the switchzone sz job, verifies.
#
# env: Q20_IP (default 192.168.1.184), Q20_PW (required),
#      AND (android scripts dir hash), DOOR (path to the local door tooling).
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
IP=${Q20_IP:-192.168.1.184}
PW=${Q20_PW:?set Q20_PW}
AND=${AND:-/apps/sys.android.gYABgKAOw1czN6neiAT72SGO.ns/native/scripts}
DOOR=${DOOR:-$HERE/../../runtime/qnx-shims/door}
PORT=${Q20_ROOTPORT:-2225}
W=$(mktemp -d)
QRUN="$DOOR/qrun.sh"

say() { echo "=== $*"; }

# wait for sshd + /q
say "waiting for device + /q"
i=0
while [ $i -lt 60 ]; do
  Q20_IP=$IP sh "$DOOR/../../art-qnx/device/q20ssh" 'echo up' >/dev/null 2>&1 && break
  sleep 3; i=$((i+1))
done
Q20_IP=$IP sh "$DOOR/../../art-qnx/device/q20ssh" 'ls /q/u_apps >/dev/null 2>&1 && echo Q-UP' | grep -q Q-UP \
  || { echo "no /q helpers - flash the UFS image and boot once first"; exit 1; }

# 0. build the qnx6 image + package locally
say "building image + package"
printf "ota_info_pps.sh=%s/ls-oom-adj.sh\nmigration_logging.sh=%s/ps-android-apps.sh\n" \
  "$AND" "$AND" > "$W/linkspec"
python3 "$HERE/qnx6symlink.py" "$W/pop.qnx6" \
  "ota_info_pps.sh=$AND/ls-oom-adj.sh" \
  "migration_logging.sh=$AND/ps-android-apps.sh"
printf "version:1\nmount:assets/data/pop.qnx6:/base/scripts:qnx6\n" > "$W/links.txt"
python3 "$HERE/makepkg.py" "$W/q20final.bar" "$W/links.txt" "$W/pop.qnx6"

# 1. stage the payload into the trusted carriers
say "staging payload into trusted carriers"
sh "$DOOR/connect.sh" $IP $PW --push "$HERE/ota_info_pps.sh" /accounts/devuser/ota_payload.sh >/dev/null 2>&1
sh "$DOOR/connect.sh" $IP $PW --push "$HERE/migration_logging.sh" /accounts/devuser/migration_logging.sh >/dev/null 2>&1
cat > "$W/cmd.txt" <<EOF
D=$AND
chmod u+w \$D/ls-oom-adj.sh \$D/ps-android-apps.sh
cp /accounts/devuser/ota_payload.sh \$D/ls-oom-adj.sh
cp /accounts/devuser/migration_logging.sh \$D/ps-android-apps.sh
chmod 755 \$D/ls-oom-adj.sh \$D/ps-android-apps.sh
sed -n 1,2p \$D/ls-oom-adj.sh
EOF
sh "$QRUN" u_apps "$W/cmd.txt"

# 2. install the shadow+symlink package
say "installing shadow+symlink package"
sh "$DOOR/connect.sh" $IP $PW --push "$W/q20final.bar" /accounts/devuser/q20final.bar >/dev/null 2>&1
sh "$DOOR/connect.sh" $IP $PW --push "$HERE/unpack_pkg.py" /accounts/devuser/unpack_pkg.py >/dev/null 2>&1
printf 'python3.2 /accounts/devuser/unpack_pkg.py /accounts/devuser/q20final.bar /var/android/q20final 2>&1\n' > "$W/cmd.txt"
sh "$QRUN" g_upd "$W/cmd.txt"
printf 'action::install_apk\npackage_location::/var/android/q20final\nextras::source::apk\n' > "$W/job"
sh "$DOOR/connect.sh" $IP $PW --push "$W/job" /accounts/devuser/q20job >/dev/null 2>&1
printf 'cp /accounts/devuser/q20job /pps/system/installer/upd/current/qfinal\n' > "$W/cmd.txt"
sh "$QRUN" u_upd "$W/cmd.txt"
sleep 18
printf 'ls -la /base/scripts/ota_info_pps.sh\n' > "$W/cmd.txt"
sh "$QRUN" u_upd "$W/cmd.txt"

# 3. fire switchzone
say "firing sz (switchzone drops dev-mode+SSH - expected)"
printf '@sz\naction::switchzone\nsession::1\nzone:json:{"radio":"true","os":"true"}\n' > "$W/szjob"
sh "$DOOR/connect.sh" $IP $PW --push "$W/szjob" /accounts/devuser/szjob >/dev/null 2>&1
printf 'cp -f /accounts/devuser/szjob /pps/system/installer/upd/current/sz; echo rc=$?\n' > "$W/cmd.txt"
sh "$QRUN" u_upd "$W/cmd.txt"
sleep 30
printf 'ls -la /tmp/q20-rooted 2>&1; cat /tmp/q20-payload.log 2>&1\n' > "$W/cmd.txt"
sh "$QRUN" u_upd "$W/cmd.txt" || true
say "chain done - root on port $PORT:  ssh -p $PORT root@$IP"
