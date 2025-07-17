FROM debian:12 AS base

RUN --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    --mount=type=tmpfs,target=/var/cache \
    --mount=type=tmpfs,target=/var/log \
    apt-get -qq update && \
    apt-get -qq --yes dist-upgrade


FROM base AS build-c

RUN --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    --mount=type=tmpfs,target=/var/cache \
    --mount=type=tmpfs,target=/var/log \
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
#   - ca-certificates
#   - curl
#   - gdb
#   - nano
#   - netcat-openbsd
#   - openssl
#   - stunnel
#   - sudo
#   - vim
#   - wget
#   - zsh

# tcpdump-port:
#   - socat
#   - tcpdump

RUN --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    --mount=type=tmpfs,target=/var/cache \
    --mount=type=tmpfs,target=/var/log \
    apt-get install --yes \
        ca-certificates \
        curl \
        gdb \
        nano \
        netcat-openbsd \
        openssl \
        socat \
        stunnel \
        sudo \
        tcpdump \
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

