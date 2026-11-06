# Device side scripts

Host side helpers for driving the Q20 over dev mode SSH, plus the runner that
executes on the phone.

* `connect.sh` installs an SSH key through blackberry-connect and holds the
  session open. Needs the device password, which it reads from `$BBPW`; it never
  prints it. A human runs this step.
* `q20ssh`, `q20put` wrap ssh and file copy with the legacy algorithms this
  device's OpenSSH 6.2 requires.
* `run_core.sh` runs on the phone, inside the staging directory produced by
  `make -f art-qnx.mk stage`. On the Classic that directory is
  `/accounts/devuser/runtime`. `APP_APK` and `APP_ACT` pick the app (the
  Prober by default). `sh run_core.sh tap <id> ... <id>=<text>` taps views
  headless and checks text; `live` puts the app on the panel (needs the
  resident root compositor; launch it detached, `( ... & )`); `snap` copies
  the last frame to `out/frame.rgba`.
* One ART process at a time on the Classic: a second one fails its fixed
  address heap reservation while another runs.
* A `q20put` cut by Wi-Fi leaves a remote `cat` holding the file open, and
  `dlopen` then fails with "Library cannot be found": kill that session.

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
