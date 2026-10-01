#!/usr/bin/env python3
"""Minimal qconn client for the Q20 (port 8000): commands + file push/pull.

Derived from the qnx8-qconn-mcp protocol reference (telnet-ish framing,
broker -> launcher/file services). No auth: dev-mode qconn executes as
devuser. Usage:
  qconn_exec.py "shell command"
  qconn_exec.py push <local> <remote>
  qconn_exec.py pull <remote> <local>
"""
import socket, sys

IAC, DONT, DO, WONT, WILL, SB, SE = 255, 254, 253, 252, 251, 250, 240
HOST, PORT = "169.254.0.1", 8000

# QNX open(2) flag values (Neutrino fcntl.h)
O_WRONLY, O_RDONLY, O_CREAT, O_TRUNC, O_RDWR = 0x0001, 0x0000, 0x0100, 0x0200, 0x0002


class Conn:
    def __init__(self):
        self.s = socket.create_connection((HOST, PORT), timeout=15)
        self.buf = b""

    def _recv(self, timeout=10.0):
        self.s.settimeout(timeout)
        try:
            chunk = self.s.recv(65536)
        except socket.timeout:
            return b"", True
        if not chunk:
            return b"", False
        out = b""
        i = 0
        while i < len(chunk):
            b = chunk[i]
            if b == IAC:
                if i + 1 >= len(chunk):
                    break
                c = chunk[i + 1]
                if c in (DO, DONT) and i + 2 < len(chunk):
                    self.s.sendall(bytes([IAC, WONT, chunk[i + 2]]))
                    i += 3
                elif c in (WILL, WONT) and i + 2 < len(chunk):
                    self.s.sendall(bytes([IAC, DONT, chunk[i + 2]]))
                    i += 3
                elif c == SB:
                    j = chunk.find(bytes([IAC, SE]), i)
                    if j < 0:
                        break
                    i = j + 2
                else:
                    i += 2
            else:
                out += bytes([b])
                i += 1
        self.buf += out
        return out, True

    def until(self, prompt, timeout=10.0):
        while prompt not in self.buf:
            _, ok = self._recv(timeout)
            if not ok:
                break
        idx = self.buf.find(prompt) + len(prompt)
        data, self.buf = self.buf[:idx], self.buf[idx:]
        return data

    def broker(self):
        self.until(b"<qconn-broker>")

    def cmd(self, svc, line, prompt):
        self.s.sendall(b"service " + svc.encode() + b"\n")
        self.until(prompt)
        self.s.sendall(line.encode() + b"\n")

    def close(self):
        self.s.close()


def exec_cmd(cmd, timeout=120.0):
    c = Conn()
    c.broker()
    c.cmd("launcher", 'start/flags run /bin/sh /bin/sh -c "%s"' % cmd.replace('\\', '\\\\').replace('"', '\\"'),
          b"<qconn-launcher>")
    c.s.settimeout(timeout)
    out = b""
    try:
        while True:
            ch = c.s.recv(65536)
            if not ch:
                break
            out += ch
    except socket.timeout:
        pass
    c.close()
    return out.decode(errors="replace")


def push_file(local, remote):
    data = open(local, "rb").read()
    c = Conn()
    c.broker()
    c.s.sendall(b"service file\n")
    c.until(b"<qconn-file>")
    c.s.sendall(('o:"%s":%x:%x\n' % (remote, O_WRONLY | O_CREAT | O_TRUNC, 0o666)).encode())
    resp = c.until(b"<qconn-file>").decode(errors="replace")
    line = resp.strip().split("\n")[0]
    if not line.startswith("o:"):
        return "ERR open: %s" % line
    fd = int(line.split(":")[1], 16)
    off = 0
    CHUNK = 16 * 1024
    while off < len(data):
        part = data[off:off + CHUNK]
        c.s.sendall(("w:%x:%x:%x\n" % (fd, off, len(part))).encode())
        c.s.sendall(part)
        c.s.sendall(b"\n")
        resp = c.until(b"<qconn-file>")
        off += len(part)
    c.s.sendall(("c:%x\n" % fd).encode())
    c.until(b"<qconn-file>")
    c.close()
    return "pushed %d bytes to %s" % (len(data), remote)


def pull_file(remote, local):
    c = Conn()
    c.broker()
    c.s.sendall(b"service file\n")
    c.until(b"<qconn-file>")
    c.s.sendall(('o:"%s":%x:%x\n' % (remote, O_RDONLY, 0)).encode())
    resp = c.until(b"<qconn-file>").decode(errors="replace")
    line = resp.strip().split("\n")[0]
    if not line.startswith("o:"):
        return "ERR open: %s" % line
    parts = line.split(":")
    fd = int(parts[1], 16)
    size = int(parts[3], 16)
    out = b""
    off = 0
    while off < size:
        n = min(2048, size - off)
        c.s.sendall(("r:%x:%x:%x\n" % (fd, off, n)).encode())
        status = c.until(b"\n").decode(errors="replace").strip()
        num = int(status.split(":")[1], 16) if status.startswith("o:") else 0
        # raw bytes follow immediately; read exactly num, then the prompt
        want = num
        while want > 0:
            c.s.settimeout(10)
            ch = c.s.recv(min(want, 65536))
            if not ch:
                break
            want -= len(ch)
            out += ch
        c.buf = b""  # discard leftover (prompt may be consumed as data)
        c.until(b"<qconn-file>")
        off += n
    c.s.sendall(("c:%x\n" % fd).encode())
    c.until(b"<qconn-file>")
    c.close()
    open(local, "wb").write(out[:size])
    return "pulled %d bytes from %s" % (size, remote)


if __name__ == "__main__":
    if len(sys.argv) >= 3 and sys.argv[1] == "push":
        print(push_file(sys.argv[2], sys.argv[3]))
    elif len(sys.argv) >= 3 and sys.argv[1] == "pull":
        print(pull_file(sys.argv[2], sys.argv[3]))
    else:
        cmd = sys.argv[1] if len(sys.argv) > 1 else "echo qconn-ok"
        print(exec_cmd(cmd))
