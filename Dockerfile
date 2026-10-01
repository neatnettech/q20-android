# Build environment for the QNX ART port.
#
# The PlayBook GCC 9.3 cross toolchain in toolchains/playbook-gcc9/ is a Linux
# x86-64 binary, so the build runs in this container even on an arm64 host.
# The repo is bind mounted at /workspace/project (see docker-compose.yml), so
# nothing is copied in here.
#
#   docker compose build
#   docker compose run --rm aosp6
#   . toolchains/playbook-gcc9/env.sh && cd runtime/art-qnx && make -f art-qnx.mk libjavacore.so
FROM --platform=linux/amd64 ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
      make \
      patch \
      file \
      python3 \
      xz-utils \
      binutils \
      libgmp10 \
      libmpfr6 \
      libmpc3 \
      zlib1g \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace/project
CMD ["/bin/bash"]
