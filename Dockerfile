FROM debian:13.6@sha256:34cd9e9fd437c0a095ec39cb2e73422c9f30821b0d0848ed74fd0d43bae4d958 AS base

RUN --mount=type=tmpfs,target=/var/lib/apt/lists \
    --mount=type=tmpfs,target=/var/cache \
    --mount=type=tmpfs,target=/var/log \
    export REBUILD_CACHE_BUSTER=2026-06-05_1 && \
    apt-get update && \
    apt-get dist-upgrade --yes

FROM base AS build-c

RUN --mount=type=tmpfs,target=/var/lib/apt/lists \
    --mount=type=tmpfs,target=/var/cache \
    --mount=type=tmpfs,target=/var/log \
    apt-get update && \
    apt-get install --yes \
        build-essential \
        cmake

COPY software/c /build/src

RUN mkdir -p /build/work && \
    cd /build/work && \
    cmake -DCMAKE_BUILD_TYPE=Release ../src && \
    cmake --build . -j$(nproc) && \
    cmake --install . --prefix /build/install


FROM base AS final

# Base-Tools:
#   - bind9-dnsutils
#   - ca-certificates
#   - curl
#   - gdb
#   - htop
#   - iperf3
#   - iputils-ping
#   - jq
#   - mtr
#   - nano
#   - netcat-openbsd
#   - openssl
#   - stunnel
#   - sudo
#   - traceroute
#   - vim
#   - wget
#   - yq
#   - zsh

# tcpdump-port:
#   - socat
#   - tcpdump

RUN --mount=type=tmpfs,target=/var/lib/apt/lists \
    --mount=type=tmpfs,target=/var/cache \
    --mount=type=tmpfs,target=/var/log \
    apt-get update && \
    apt-get install --yes \
        bind9-dnsutils \
        ca-certificates \
        curl \
        gdb \
        htop \
        iperf3 \
        iputils-ping \
        mtr \
        nano \
        netcat-openbsd \
        openssl \
        socat \
        stunnel \
        sudo \
        tcpdump \
        traceroute \
        vim \
        wget \
        zsh

# Prepare sudo to allow everything
COPY files/sudoers /etc/sudoers.d/developerimage

# Install Raw Tools
COPY software/raw /

# Install C Tools
COPY --from=build-c /build/install /

# Use ZSH as the default shell
CMD ["/usr/bin/zsh"]

