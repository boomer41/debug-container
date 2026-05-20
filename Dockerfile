FROM debian:13.5@sha256:4ae67669760b807c19f23902a3fd7c121a6a70cf2ae709035674b23e712e4d62 AS base

RUN --mount=type=tmpfs,target=/var/lib/apt/lists \
    --mount=type=tmpfs,target=/var/cache \
    --mount=type=tmpfs,target=/var/log \
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

