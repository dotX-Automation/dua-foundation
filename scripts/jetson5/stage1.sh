#!/bin/sh

# Stage 1 script for jetson5.
#
# Roberto Masocco <r.masocco@dotxautomation.com>
#
# March 13, 2026

# Copyright 2026 dotX Automation s.r.l.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

# Create internal users group
groupadd -r internal

# Update CMake version to the latest available at Kitware
apt-get remove --purge --auto-remove -y cmake
wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /usr/share/keyrings/kitware-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ focal main" | tee /etc/apt/sources.list.d/kitware.list
apt-get update
apt-get install -y --no-install-recommends \
  cmake=3.28.1-0kitware1ubuntu20.04.1 \
  cmake-data=3.28.1-0kitware1ubuntu20.04.1
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*/apt/lists/*

# Purge existing OpenCV installation
apt-get update
apt-get remove --purge --auto-remove -y \
  libopencv* \
  opencv*
rm -rf /usr/local/include/opencv4
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*/apt/lists/*

# Purge existing numpy matplotlib installations
apt-get update
apt-get remove --purge --auto-remove -y \
  python3-matplotlib \
  python3-numpy
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*/apt/lists/*
pip uninstall numpy -y

# Configure Ubuntu 22.04 repositories to download the latest versions of some packages
# NOTES
# - This is mostly manually configured, and is due to subsequent builds whose
#   sources get updated from time to time, raising some version requirements.
#   The only way to configure this properly is to intervene manually when
#   something breaks down the line.
# - Package pin priorities are set to ensure that only selected packages
#   are installed from the Ubuntu 22.04 repositories, while the rest of the
#   packages are installed from the Ubuntu 20.04 repositories.
# - Packages currently handled like this include are:
# -   libasio-dev (Fast DDS dependency, also in ROS 2 source build)
echo "deb http://ports.ubuntu.com/ubuntu-ports jammy main universe" | tee /etc/apt/sources.list.d/jammy.list
printf "Package: *\nPin: release n=jammy\nPin-Priority: 100\n\n" > /etc/apt/preferences.d/jammy
printf "Package: libasio-dev\nPin: release n=jammy\nPin-Priority: 1001\n\n" >> /etc/apt/preferences.d/jammy

# Install basic utilities, dependencies, and development tools
# These include:
# - C/C++ toolchain and debuggers
# - Python 3 interpreter, testers, basic modules and scientific libraries
# - Linters
# - OpenCV dependencies for ARMv8 systems
# - Boost C++ libraries
# - System utilities
# - Zsh shell
# Then, add universe repository
apt-get update
apt-get install -y --no-install-recommends \
  apt-utils \
  bind9-dnsutils \
  build-essential \
  ccache \
  cppcheck \
  dialog \
  dirmngr \
  dmidecode \
  file \
  fuse3 \
  g++ \
  gcc \
  gdb \
  gdbserver \
  gfortran \
  git \
  gnupg2 \
  gstreamer1.0-alsa \
  gstreamer1.0-pulseaudio \
  gstreamer1.0-rtsp \
  gstreamer1.0-tools \
  htop \
  iperf3 \
  iproute2 \
  iputils-ping \
  less \
  lcov \
  libasio-dev \
  libatlas-base-dev \
  libavcodec-dev \
  libavformat-dev \
  libavresample-dev \
  libavutil-dev \
  libboost-all-dev \
  libcanberra-gtk* \
  libceres-dev \
  libdc1394-22-dev \
  libfaac-dev \
  libgeographic-dev \
  libgflags-dev \
  libgoogle-glog-dev \
  libgstreamer1.0-dev \
  libgstreamer-plugins-base1.0-dev \
  libgtk2.0-dev \
  libgtk-3-dev \
  libhdf5-dev \
  libjpeg-dev \
  libmp3lame-dev \
  libopencore-amrnb-dev \
  libpng-dev \
  libprotobuf-dev \
  libssl-dev \
  libswresample-dev \
  libswscale-dev \
  libtheora-dev \
  libtiff-dev \
  libtinyxml2-dev \
  libv4l-dev \
  libvorbis-dev \
  libx264-dev \
  libxine2-dev \
  libxml2-utils \
  libxvidcore-dev \
  locales \
  lsb-core \
  lsb-release \
  lsof \
  make \
  minicom \
  nano \
  nfs-common \
  ninja-build \
  openssh-client \
  openssl \
  pkg-config \
  protobuf-compiler \
  python3-argcomplete \
  python3-autopep8 \
  python3-dev \
  python3-pygments \
  python3-pytest-cov \
  python3-pytest-pylint \
  python3-vcstools \
  python3-venv \
  shellcheck \
  software-properties-common \
  sshfs \
  sudo \
  traceroute \
  uncrustify \
  unzip \
  v4l-utils \
  valgrind \
  vim \
  wget \
  whois \
  zip \
  zsh \
  zsh-doc \
  zstd
add-apt-repository universe
apt-get autoremove -y
apt-get autoclean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*/apt/lists/*

# Install MediaMTX
wget -O /tmp/mediamtx.tar.gz https://github.com/bluenviron/mediamtx/releases/download/${MEDIAMTX_VERSION}/mediamtx_${MEDIAMTX_VERSION}_linux_${MEDIAMTX_ARCH}.tar.gz
tar -xzf /tmp/mediamtx.tar.gz
mv mediamtx /usr/local/bin/mediamtx
mv mediamtx.yml /etc/mediamtx.yml
rm /tmp/mediamtx.tar.gz

# Configure Git to accept different ownerships for local repository clones
git config --system --add safe.directory '*'

# Install Java 17
apt-get update
apt-get install -y --no-install-recommends \
  ant \
  libvecmath-java \
  openjdk-17-jdk \
  openjdk-17-jre
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*/apt/lists/*
update-alternatives --set java $(update-alternatives --list java | grep "java-17")

# Install Rust toolchain
cd /opt
/opt/scripts/install_rust.sh jetson5 1.85.0
chgrp internal /opt/scripts/install_rust.sh
chmod g+rwx /opt/scripts/install_rust.sh
chgrp -R internal /opt/rust
chmod -R g+rw /opt/rust
cd /root

# Install nlohmann/json C++ library
cd /opt
/opt/scripts/install_nlohmann_json.sh jetson5 3.12.0
chgrp internal /opt/scripts/install_nlohmann_json.sh
chmod g+rwx /opt/scripts/install_nlohmann_json.sh
cd /root
