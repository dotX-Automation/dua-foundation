#!/bin/sh

# Stage 1 script for x86-dev.
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

# Install basic utilities, dependencies, and development tools
# These include:
# - C/C++ toolchain and debuggers
# - Python 3 interpreter, testers, basic modules and scientific libraries
# - Linters
# - OpenCV dependencies for x86 systems
# - Boost C++ libraries
# - System utilities
# - Zsh shell
# Then, add universe repository
apt-get update
apt-get install -y --no-install-recommends \
  apt-utils \
  bind9-dnsutils \
  build-essential \
  ca-certificates \
  ccache \
  cmake \
  cppcheck \
  curl \
  dialog \
  dirmngr \
  dmidecode \
  file \
  fuse3 \
  g++ \
  gcc \
  gdb \
  gdbserver \
  git \
  gnupg2 \
  gstreamer1.0-alsa \
  gstreamer1.0-pulseaudio \
  gstreamer1.0-tools \
  htop \
  iperf3 \
  iproute2 \
  iputils-ping \
  less \
  lcov \
  libasio-dev \
  libavcodec-dev \
  libavformat-dev \
  libavutil-dev \
  libboost-all-dev \
  libceres-dev \
  libdc1394-dev \
  libgeographiclib-dev \
  libgtk2.0-dev \
  libjpeg-dev \
  libpng-dev \
  libssl-dev \
  libswresample-dev \
  libswscale-dev \
  libtbb-dev \
  libtiff-dev \
  libtinyxml2-dev \
  libxml2-utils \
  locales \
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
  python3 \
  python3-argcomplete \
  python3-autopep8 \
  python3-dev \
  python3-pip \
  python3-pygments \
  python3-pytest-pylint \
  python3-venv \
  shellcheck \
  software-properties-common \
  sshfs \
  sudo \
  traceroute \
  uncrustify \
  unzip \
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

# Configure language and locale
locale-gen en_US.UTF-8
update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

# Install Rust toolchain
cd /opt
/opt/scripts/install_rust.sh x86-dev 1.85.0
chgrp internal /opt/scripts/install_rust.sh
chmod g+rwx /opt/scripts/install_rust.sh
chgrp -R internal /opt/rust
chmod -R g+rw /opt/rust
cd /root

# Install nlohmann/json C++ library
cd /opt
/opt/scripts/install_nlohmann_json.sh x86-dev 3.12.0
chgrp internal /opt/scripts/install_nlohmann_json.sh
chmod g+rwx /opt/scripts/install_nlohmann_json.sh
cd /root

# Install ROS 2
cd /opt
/opt/scripts/install_ros2.sh x86-dev jazzy 8294968ee233629c8fb223b2a29bb93ccce7480a
chgrp internal /opt/scripts/install_ros2.sh
chmod g+rwx /opt/scripts/install_ros2.sh
chgrp -R internal /opt/ros
chmod -R g+rw /opt/ros
chgrp -R internal /opt/rust
chmod -R g+rw /opt/rust
cd /root

# Install Gazebo
cd /opt
/opt/scripts/install_gazebo.sh x86-dev harmonic jazzy
chgrp internal /opt/scripts/install_gazebo.sh
chmod g+rwx /opt/install_gazebo.sh
cd /root
