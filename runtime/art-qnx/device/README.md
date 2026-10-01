# Device side scripts

Host side helpers for driving the Q20 over dev mode SSH, plus the runner that
executes on the phone.

* `connect.sh` installs an SSH key through blackberry-connect and holds the
  session open. Needs the device password, which it reads from `$BBPW`; it never
  prints it. A human runs this step.
* `q20ssh`, `q20put` wrap ssh and file copy with the legacy algorithms this
  device's OpenSSH 6.2 requires.
* `run_core.sh` runs on the phone, inside the staging directory produced by
  `make -f art-qnx.mk stage`.

Order of operations:

```
sh runtime/art-qnx/device/connect.sh          # leave running, holds sshd up
runtime/art-qnx/device/q20ssh 'uname -a'      # verify
docker compose run --rm --entrypoint /bin/bash aosp6 -c \
  '. toolchains/playbook-gcc9/env.sh && cd runtime/art-qnx && make -f art-qnx.mk stage'
# push the staging tree, then on the device: sh run_core.sh all
```

Why the odd pieces:

* The device accepts only an RSA 4096 public key with no comment field. A
  comment gives "Invalid contents after ssh key"; 2048 bits gives "too small
  (4096 bit minimum)".
* blackberry-connect must keep running. That process holds the authorized
  session, and sshd stops listening when it exits.
* scp does not work against this sshd. Use `q20put`, or tar over ssh for trees.
* The phone's `/bin/sh` is ksh and has no `head`, `tr`, `nohup`, `id` or
  `whoami`.
