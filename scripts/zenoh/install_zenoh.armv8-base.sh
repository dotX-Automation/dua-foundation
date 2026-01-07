#!/bin/sh

# Zenoh libraries and tools installation script.
#
# Roberto Masocco <r.masocco@dotxautomation.com>
#
# February 11, 2025

# Copyright 2025 dotX Automation s.r.l.
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

# This script assumes that:
# - a Rust toolchain has been installed and its environment is configured;
# - the desired Python virtual (or system) environment has been activated.

set -e

# Get the requested Zenoh version
ZENOH_VERSION="${1-}"
ZENOH_ARCH="aarch64-unknown-linux-gnu"
ZENOH_PICO_ARCH="linux-arm64"

mkdir -p /etc/zenoh /opt/zenoh

# Install standalone Zenoh router, plugins, and sample configuration file
wget -O /etc/zenoh/DEFAULT_ZENOH_CONFIG.json5 https://raw.githubusercontent.com/eclipse-zenoh/zenoh/refs/tags/${ZENOH_VERSION}/DEFAULT_CONFIG.json5
wget -O /tmp/zenoh-standalone.zip https://github.com/eclipse-zenoh/zenoh/releases/download/${ZENOH_VERSION}/zenoh-${ZENOH_VERSION}-${ZENOH_ARCH}-standalone.zip
unzip /tmp/zenoh-standalone.zip -d /tmp
mv /tmp/zenohd /usr/local/bin/zenohd
mv /tmp/libzenoh_plugin_rest.so /usr/local/lib/
mv /tmp/libzenoh_plugin_storage_manager.so /usr/local/lib/
rm /tmp/zenoh-standalone.zip
chmod a+x /usr/local/bin/zenohd

# Install Zenoh DDS Bridge, plugin, and sample configuration file
wget -O /etc/zenoh/DEFAULT_DDS_CONFIG.json5 https://raw.githubusercontent.com/eclipse-zenoh/zenoh-plugin-dds/refs/tags/${ZENOH_VERSION}/DEFAULT_CONFIG.json5
wget -O /tmp/zenoh-plugin-dds-standalone.zip https://github.com/eclipse-zenoh/zenoh-plugin-dds/releases/download/${ZENOH_VERSION}/zenoh-plugin-dds-${ZENOH_VERSION}-${ZENOH_ARCH}-standalone.zip
unzip /tmp/zenoh-plugin-dds-standalone.zip -d /tmp
mv /tmp/zenoh-bridge-dds /usr/local/bin/zenoh-bridge-dds
mv /tmp/libzenoh_plugin_dds.so /usr/local/lib/
rm /tmp/zenoh-plugin-dds-standalone.zip
chmod a+x /usr/local/bin/zenoh-bridge-dds

# Install Zenoh ROS2DDS Bridge, plugin, and sample configuration file
wget -O /etc/zenoh/DEFAULT_ROS2DDS_CONFIG.json5 https://raw.githubusercontent.com/eclipse-zenoh/zenoh-plugin-ros2dds/refs/tags/${ZENOH_VERSION}/DEFAULT_CONFIG.json5
wget -O /tmp/zenoh-plugin-ros2dds-standalone.zip https://github.com/eclipse-zenoh/zenoh-plugin-ros2dds/releases/download/${ZENOH_VERSION}/zenoh-plugin-ros2dds-${ZENOH_VERSION}-${ZENOH_ARCH}-standalone.zip
unzip /tmp/zenoh-plugin-ros2dds-standalone.zip -d /tmp
mv /tmp/zenoh-bridge-ros2dds /usr/local/bin/zenoh-bridge-ros2dds
mv /tmp/libzenoh_plugin_ros2dds.so /usr/local/lib/
rm /tmp/zenoh-plugin-ros2dds-standalone.zip
chmod a+x /usr/local/bin/zenoh-bridge-ros2dds

chgrp -R internal /etc/zenoh
chmod -R g+rw /etc/zenoh
ldconfig

# Install Zenoh Python API
pip install eclipse-zenoh

# Build and install Zenoh C API, cleanup
git clone --depth 1 --single-branch \
  --branch "${ZENOH_VERSION}" \
  https://github.com/eclipse-zenoh/zenoh-c.git \
  /opt/zenoh/zenoh-c
mkdir -p /opt/zenoh/zenoh-c/build
cd /opt/zenoh/zenoh-c/build
cmake \
  -DBUILD_SHARED_LIBS=ON \
  -DZENOHC_BUILD_WITH_SHARED_MEMORY=true \
  ..
cmake --build . --config Release
cmake --build . --target install
cd ../..
rm -rf /opt/zenoh/zenoh-c/build
ldconfig

# Install Zenoh-Pico
wget -O /tmp/zenoh-pico.zip https://github.com/eclipse-zenoh/zenoh-pico/releases/download/${ZENOH_VERSION}/zenoh-pico-${ZENOH_VERSION}-${ZENOH_PICO_ARCH}-debian.zip
unzip /tmp/zenoh-pico.zip -d /tmp
dpkg -i /tmp/libzenohpico_*.deb /tmp/libzenohpico-dev_*.deb
rm /tmp/zenoh-pico.zip /tmp/libzenohpico_*.deb /tmp/libzenohpico-dev_*.deb
ldconfig

# Install Zenoh C++ API
git clone --depth 1 --single-branch \
  --branch "${ZENOH_VERSION}" \
  https://github.com/eclipse-zenoh/zenoh-cpp.git \
  /opt/zenoh/zenoh-cpp
mkdir -p /opt/zenoh/zenoh-cpp/build
cd /opt/zenoh/zenoh-cpp/build
cmake \
  -DZENOHCXX_ZENOHC=ON \
  -DZENOHCXX_ZENOHPICO=ON \
  ..
cmake --install .
cd ../..
rm -rf /opt/zenoh/zenoh-cpp/build
ldconfig
