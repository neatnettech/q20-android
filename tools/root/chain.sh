#!/bin/sh
# Post-flash root chain: assumes first boot after UFS flash (/q helpers up).
# Steps: stage v2 payload in the trusted android-dir carrier, install the
# shadow+symlink package, fire switchzone, verify.
set -e
D=/Users/piotrpestka/github/q20-android/runtime/qnx-shims/door
T=/private/var/folders/03/bdcsj20x1q372qfxl9pbffz40000gn/T/opencode/q20-rcfs
QRUN="$D/qrun.sh"
AND=/apps/sys.android.gYABgKAOw1czN6neiAT72SGO.ns/native/scripts
IP=192.168.1.184

say() { echo "=== $*"; }

# wait for sshd
say "waiting for device"
i=0
while [ $i -lt 60 ]; do
  Q20_IP=$IP sh "$D/../../art-qnx/device/q20ssh" 'echo up' >/dev/null 2>&1 && break
  sleep 3; i=$((i+1))
done
Q20_IP=$IP sh "$D/../../art-qnx/device/q20ssh" 'ls /q/u_apps >/dev/null 2>&1 && echo Q-UP' || { echo "no /q"; exit 1; }

# 1. stage the payload into the trusted carriers
say "staging payload"
sh "$D/connect.sh" $IP drstone --push "$T/ota_info_pps.sh" /accounts/devuser/ota_payload.sh >/dev/null 2>&1
sh "$D/connect.sh" $IP drstone --push "$T/migration_logging.sh" /accounts/devuser/migration_logging.sh >/dev/null 2>&1
cat > "$T/cmd.txt" <<EOF
D=$AND
chmod u+w \$D/ls-oom-adj.sh \$D/ps-android-apps.sh
cp /accounts/devuser/ota_payload.sh \$D/ls-oom-adj.sh
cp /accounts/devuser/migration_logging.sh \$D/ps-android-apps.sh
chmod 755 \$D/ls-oom-adj.sh \$D/ps-android-apps.sh
sed -n 1,2p \$D/ls-oom-adj.sh
EOF
sh "$QRUN" u_apps "$T/cmd.txt"

# 2. install the shadow+symlink package
say "installing q20final"
sh "$D/connect.sh" $IP drstone --push "$T/q20final.bar" /accounts/devuser/q20final.bar >/dev/null 2>&1
sh "$D/connect.sh" $IP drstone --push "$T/unpackfinal.py" /accounts/devuser/unpackfinal.py >/dev/null 2>&1
printf 'python3.2 /accounts/devuser/unpackfinal.py 2>&1\n' > "$T/cmd.txt"
sh "$QRUN" g_upd "$T/cmd.txt"
sh "$D/connect.sh" $IP drstone --push "$T/q20job10" /accounts/devuser/q20job10 >/dev/null 2>&1
printf 'cp /accounts/devuser/q20job10 /pps/system/installer/upd/current/qfinal\n' > "$T/cmd.txt"
sh "$QRUN" u_upd "$T/cmd.txt"
sleep 18
printf 'ls -la /base/scripts/ota_info_pps.sh\n' > "$T/cmd.txt"
sh "$QRUN" u_upd "$T/cmd.txt"

# 3. fire switchzone
say "firing sz"
sh "$D/connect.sh" $IP drstone --push "$T/szjob" /accounts/devuser/szjob >/dev/null 2>&1
printf 'cp -f /accounts/devuser/szjob /pps/system/installer/upd/current/sz; echo rc=$?\n' > "$T/cmd.txt"
sh "$QRUN" u_upd "$T/cmd.txt"
sleep 30
printf 'ls -la /tmp/q20-rooted 2>&1; cat /tmp/q20-payload.log 2>&1\n' > "$T/cmd.txt"
sh "$QRUN" u_upd "$T/cmd.txt" || true
say "chain done - try: ssh -p 2222 root@$IP"
