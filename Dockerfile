# Use an appropriate base image
FROM --platform=linux/arm64 ubuntu:22.04

# Set environment variables for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies
RUN apt-get update && apt-get install -y \
    git \
    gcc-aarch64-linux-gnu \
    gcc-arm-linux-gnueabihf \
    pkg-config \
    python3 \
    python3-sphinx \
    python3-venv \
    python3-sphinx \       
    python3-tomli \
    libglib2.0-dev \
    libpixman-1-dev \
    libaio-dev \
    libbluetooth-dev \
    libcapstone-dev \
    libbrlapi-dev \
    libbz2-dev \
    libcap-ng-dev \
    libcurl4-gnutls-dev \
    libgtk-3-dev \
    libibverbs-dev \
    libjpeg8-dev \
    libncurses5-dev \
    libnuma-dev \
    librbd-dev \
    librdmacm-dev \
    libsasl2-dev \
    libsdl2-dev \
    libseccomp-dev \
    libsnappy-dev \
    libssh-dev \
    libvde-dev \
    libvdeplug-dev \
    libvte-2.91-dev \
    libxen-dev \
    liblzo2-dev \
    valgrind \
    ninja-build \
    qemu-user-static \
    && rm -rf /var/lib/apt/lists/*

# Clone QEMU source
RUN git clone https://git.qemu.org/git/qemu.git /qemu

WORKDIR /qemu

# Checkout the desired version if needed
RUN git fetch --tags && \
    git checkout $(git describe --tags `git rev-list --tags --max-count=1`)

# Copy your architecture file (arch.txt) if needed
COPY arch.txt /qemu/arch.txt

# Parse the architecture
RUN ARCH=aarch64 && \
    ./configure --target-list=aarch64-softmmu,arm-linux-user --enable-gtk --enable-sdl && \
    make -j$(nproc)

# Output the binaries to the specified directory
RUN mkdir -p /qemu/build_output && \
    cp -r /qemu/build/qemu-system-aarch64 /qemu/build_output/ && \
    ls /qemu/build_output

# Add GitHub credentials and push to the repo
ARG DOCKER_NAME
ARG DOCKER_EMAIL
ARG DOCKER_TOKEN

RUN git config --global user.name "${DOCKER_NAME}" && \
    git config --global user.email "${DOCKER_EMAIL}" && \
    git add /qemu/build_output/* && \
    git commit -m "Add QEMU binaries" && \
    git push https://${DOCKER_NAME}:${DOCKER_TOKEN}@github.com/2Petro/Qemu-build-ci.git Qemu-arm   
