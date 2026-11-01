# The trusted-inode exec channel

The one writable inode on the boot-time trusted list is
`/var/exfat/fs-exfat.so`: `pathtrust.sh`'s exfat hack creates a 0-byte
stub there and trusts its *inode* when the exfat databar is absent. Trust
follows the dev/ino, not the content.

- **Overwrite it in place** (`cat bin > /var/exfat/fs-exfat.so`, same
  inode) and the content execs as root - arbitrary host-built ARM ELFs,
  bypassing both the pathtrust lockdown (trust requests fail post-boot,
  EPERM even for root) and the exec gate.
- It is also the **kill-proof sshd home**: running sshd from there makes
  the process name "fs-exfat.so", immune to the system's `slay sshd` and
  the switchzone cleanup that killed the plain sshd.
- The payload v8.1 restores the sshd there at every boot (size check: the
  boot stub is < 100 KB, sshd is 308 KB).

Known limits: one inode, so it holds either the sshd or a one-shot tool
(the A7 compositor was swapped in and out the same way - back up whatever
it replaces). A full UFS flash wipes it; the boot recreates the stub.
