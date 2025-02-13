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

# Get the requested Zenoh version
ZENOH_VERSION="${1-}"

mkdir /etc/zenoh /opt/zenoh

# Install Zenoh router
wget -O /usr/local/bin/zenohd http://160.80.97.139:8087/Software/DUA/Zenoh/${ZENOH_VERSION}/zenoh-${ZENOH_VERSION}-x86_64-unknown-linux-gnu-standalone/zenohd
chmod a+x /usr/local/bin/zenohd

# Install zenohd plugins:
# - REST
# - Storage manager
wget -O /usr/local/lib/libzenoh_plugin_rest.so http://160.80.97.139:8087/Software/DUA/Zenoh/${ZENOH_VERSION}/zenoh-${ZENOH_VERSION}-x86_64-unknown-linux-gnu-standalone/libzenoh_plugin_rest.so
wget -O /usr/local/lib/libzenoh_plugin_storage_manager.so http://160.80.97.139:8087/Software/DUA/Zenoh/${ZENOH_VERSION}/zenoh-${ZENOH_VERSION}-x86_64-unknown-linux-gnu-standalone/libzenoh_plugin_storage_manager.so

# Install zenohd sample configuration file
wget -O /etc/zenoh/DEFAULT_ZENOHD_CONFIG.json5 http://160.80.97.139:8087/Software/DUA/Zenoh/${ZENOH_VERSION}/zenoh-${ZENOH_VERSION}-x86_64-unknown-linux-gnu-standalone/DEFAULT_CONFIG.json5

# Install Zenoh ROS2DDS Bridge, plugin, and sample configuration file
wget -O /usr/local/bin/zenoh-bridge-ros2dds http://160.80.97.139:8087/Software/DUA/Zenoh/${ZENOH_VERSION}/zenoh-plugin-ros2dds-${ZENOH_VERSION}-x86_64-unknown-linux-gnu-standalone/zenoh-bridge-ros2dds
chmod a+x /usr/local/bin/zenoh-bridge-ros2dds
wget -O /usr/local/lib/libzenoh_plugin_ros2dds.so http://160.80.97.139:8087/Software/DUA/Zenoh/${ZENOH_VERSION}/zenoh-plugin-ros2dds-${ZENOH_VERSION}-x86_64-unknown-linux-gnu-standalone/libzenoh_plugin_ros2dds.so
wget -O /etc/zenoh/DEFAULT_ROS2DDS_CONFIG.json5 http://160.80.97.139:8087/Software/DUA/Zenoh/${ZENOH_VERSION}/zenoh-plugin-ros2dds-${ZENOH_VERSION}-x86_64-unknown-linux-gnu-standalone/DEFAULT_CONFIG.json5

# Install Zenoh DDS Bridge, plugin, and sample configuration file
wget -O /usr/local/bin/zenoh-bridge-dds http://160.80.97.139:8087/Software/DUA/Zenoh/${ZENOH_VERSION}/zenoh-plugin-dds-${ZENOH_VERSION}-x86_64-unknown-linux-gnu-standalone/zenoh-bridge-dds
chmod a+x /usr/local/bin/zenoh-bridge-dds
wget -O /usr/local/lib/libzenoh_plugin_dds.so http://160.80.97.139:8087/Software/DUA/Zenoh/${ZENOH_VERSION}/zenoh-plugin-dds-${ZENOH_VERSION}-x86_64-unknown-linux-gnu-standalone/libzenoh_plugin_dds.so
wget -O /etc/zenoh/DEFAULT_DDS_CONFIG.json5 http://160.80.97.139:8087/Software/DUA/Zenoh/${ZENOH_VERSION}/zenoh-plugin-dds-${ZENOH_VERSION}-x86_64-unknown-linux-gnu-standalone/DEFAULT_CONFIG.json5

ldconfig

# Install Zenoh Python API
pip install eclipse-zenoh

# Build and install Zenoh C API, cleanup
git clone --depth 1 --single-branch \
  --branch "${ZENOH_VERSION}" \
  https://github.com/eclipse-zenoh/zenoh-c.git \
  /opt/zenoh/zenoh-c
mkdir /opt/zenoh/zenoh-c/build
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
wget -O /tmp/libzenohpico.deb http://160.80.97.139:8087/Software/DUA/Zenoh/${ZENOH_VERSION}/zenoh-pico-${ZENOH_VERSION}-linux-x64-debian/libzenohpico_${ZENOH_VERSION}_amd64.deb
wget -O /tmp/libzenohpico-dev.deb http://160.80.97.139:8087/Software/DUA/Zenoh/${ZENOH_VERSION}/zenoh-pico-${ZENOH_VERSION}-linux-x64-debian/libzenohpico-dev_${ZENOH_VERSION}_amd64.deb
dpkg -i /tmp/libzenohpico.deb /tmp/libzenohpico-dev.deb
rm /tmp/libzenohpico.deb /tmp/libzenohpico-dev.deb
ldconfig

# Install Zenoh C++ API
git clone --depth 1 --single-branch \
  --branch "${ZENOH_VERSION}" \
  https://github.com/eclipse-zenoh/zenoh-cpp.git \
  /opt/zenoh/zenoh-cpp
mkdir /opt/zenoh/zenoh-cpp/build
cd /opt/zenoh/zenoh-cpp/build
cmake \
  -DZENOHCXX_ZENOHC=ON \
  -DZENOHCXX_ZENOHPICO=ON \
  ..
cmake --install .
cd ../..
rm -rf /opt/zenoh/zenoh-cpp/build
ldconfig
