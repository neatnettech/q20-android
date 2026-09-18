# Host validation + QNX cross compile for the qnx-shims.
#
# make test      host build, runs the futex shim self-checks (Linux pthreads)
# make qnx       cross compile the shims for QNX armle-v7 (requires the
#                playbook gcc toolchain, see toolchains/playbook-gcc/README.md)
# make check-qnx validate the QNX ELF ABI (needs the toolchain's readelf)

CC ?= cc
QNXCC ?= arm-blackberry-qnx8eabi-gcc
QNXREADELF ?= $(QNX_PREBUILT)/bin/readelf

CFLAGS = -Wall -Wextra -O2

.PHONY: test qnx check-qnx clean

test: test_futex
	./test_futex

test_futex: futex.c test_futex.c futex.h
	$(CC) $(CFLAGS) -pthread -o $@ futex.c test_futex.c

qnx: futex_qnx.o proc_qnx.o

futex_qnx.o: futex.c futex.h
	$(QNXCC) $(CFLAGS) -c futex.c -o $@

proc_qnx.o: proc.c proc.h
	$(QNXCC) $(CFLAGS) -c proc.c -o $@

check-qnx: futex_qnx.o
	$(QNXREADELF) -h futex_qnx.o | grep -E "Class|Machine|Flags"
	$(QNXREADELF) -d futex_qnx.o | grep -E "NEEDED" || true

clean:
	rm -f test_futex *.o
