# Host validation + QNX cross compile for the qnx-shims.
#
# make test      host build, runs the futex shim self-checks (Linux pthreads)
# make qnx       cross compile the shims for QNX armle-v7 (requires the
#                playbook gcc toolchain, see toolchains/playbook-gcc/README.md)
# make check-qnx validate the QNX ELF ABI (needs the toolchain's readelf)
# make probes    cross compile the Screen probes (screen_probe, navigator_probe)

CC ?= cc
QNXCC ?= arm-blackberry-qnx8eabi-gcc
QNXREADELF ?= $(QNX_PREBUILT)/bin/readelf

CFLAGS = -Wall -Wextra -O2

.PHONY: test qnx check-qnx probes clean

test: test_futex
	./test_futex

test_futex: futex.c test_futex.c futex.h
	$(CC) $(CFLAGS) -pthread -o $@ futex.c test_futex.c

qnx: futex_qnx.o proc_qnx.o

futex_qnx.o: futex.c futex.h
	$(QNXCC) $(CFLAGS) -c futex.c -o $@

proc_qnx.o: proc.c proc.h
	$(QNXCC) $(CFLAGS) -c proc.c -o $@

# The Screen probes (A4 screen_probe, A7 navigator_probe). Link the sysroot's
# DYNAMIC libscreen for its symbols and bake /base/usr/lib so the device loads
# its own: libscreenS.a is the 6.5 SDK static copy, which speaks an
# incompatible protocol and dies on array properties (bringup-log.md, A4).
SCREEN_LIBS ?= -L$(QNX_PREBUILT)/usr/lib -lscreen -lsocket -Wl,-rpath,/base/usr/lib

probes: screen_probe navigator_probe

screen_probe navigator_probe: %: %.c
	$(QNXCC) $(CFLAGS) -o $@ $< $(SCREEN_LIBS)

check-qnx: futex_qnx.o
	$(QNXREADELF) -h futex_qnx.o | grep -E "Class|Machine|Flags"
	$(QNXREADELF) -d futex_qnx.o | grep -E "NEEDED" || true

clean:
	rm -f test_futex screen_probe navigator_probe *.o
