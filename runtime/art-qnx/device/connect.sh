#!/bin/sh
# Install an SSH key on the Q20 in development mode and hold the session open.
#
# The device password comes from $BBPW and is never printed:
#   read -rs "?Q20 dev mode password: " BBPW && echo && BBPW="$BBPW" sh connect.sh
#
# Leave this running. blackberry-connect holds the authorized session, and the
# device stops listening on port 22 when it exits.
#
# Key requirements, both learned the hard way: RSA 4096 (smaller is refused with
# "too small (4096-bit minimum)") and no comment field (a comment is refused
# with "Invalid contents after ssh key").
set -e
IP=${Q20_IP:-169.254.0.1}
KEY=${Q20_KEY:-$HOME/.q20/id_rsa_q20}
JAVA=${JAVA:-$(command -v java || echo /opt/homebrew/opt/openjdk/bin/java)}
JAR=${CONNECT_JAR:-$(cd "$(dirname "$0")/../../.." && pwd)/toolchains/playbook-gcc9/qnx650/x86_64-linux/lib/Connect.jar}

[ -n "$BBPW" ] || { echo "BBPW is not set. Run:"; echo '  read -rs "?password: " BBPW && echo && BBPW="$BBPW" sh '"$0"; exit 2; }
[ -x "$JAVA" ] || { echo "no java at $JAVA; set JAVA=..."; exit 2; }
[ -f "$JAR" ] || { echo "no Connect.jar at $JAR; set CONNECT_JAR=..."; exit 2; }

if [ ! -f "$KEY" ]; then
  mkdir -p "$(dirname "$KEY")"
  ssh-keygen -t rsa -b 4096 -N "" -C "" -f "$KEY" >/dev/null
  echo "generated $KEY"
fi
# Strip everything after the blob: the device rejects a comment field.
awk '{printf "%s %s\n", $1, $2}' "$KEY.pub" > "$KEY.pub.nocomment"

echo "installing $KEY.pub.nocomment on $IP"
"$JAVA" -jar "$JAR" "$IP" -password "$BBPW" -sshPublicKey "$KEY.pub.nocomment"
