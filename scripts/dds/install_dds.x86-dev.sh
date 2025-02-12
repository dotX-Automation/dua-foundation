#!/bin/sh

# DDS implementations installation script.
#
# Roberto Masocco <r.masocco@dotxautomation.com>
#
# February 12, 2025

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

# Get the requested Fast DDS version
FASTDDS_VERSION="${1-}"

# Get the requested Cyclone DDS version
CYCLONEDDS_VERSION="${2-}"

mkdir /opt/dds
cd /opt/dds

# Clone and build Fast DDS
mkdir Fast-DDS
cd Fast-DDS
wget https://raw.githubusercontent.com/eProsima/Fast-DDS/$FASTDDS_VERSION/fastrtps.repos
mkdir src
vcs import src < fastrtps.repos
colcon build \
  --event-handlers console_direct+ \
  --packages-up-to fastrtps fastddsgen \
  --cmake-args \
    -DBUILD_SHARED_LIBS=ON \
    -DSECURITY=OFF \
    -DSHM_TRANSPORT_DEFAULT=ON \
    -DCOMPILE_EXAMPLES=OFF \
    -DINSTALL_EXAMPLES=OFF \
    -DBUILD_DOCUMENTATION=OFF \
    -DCHECK_DOCUMENTATION=OFF \
    -DSTRICT_REALTIME=OFF \
    -DSQLITE3_SUPPORT=ON \
    -DAPPEND_PROJECT_NAME_TO_INCLUDEDIR=OFF \
    -DUSE_THIRDPARTY_SHARED_MUTEX=OFF \
    -DSANITIZER=OFF
    # Tests are disabled by default

# Cleanup
rm -rf build log

# Clone and build Cyclone DDS
cd /opt/dds
git clone --single-branch \
  --branch "$CYCLONEDDS_VERSION" \
  https://github.com/eclipse-cyclonedds/cyclonedds.git
cd cyclonedds
mkdir build install
cd build
cmake \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_INSTALL_PREFIX=/opt/dds/cyclonedds/install \
  -DBUILD_EXAMPLES=OFF \
  -DBUILD_TESTING=OFF \
  -DBUILD_IDLC=ON \
  -DBUILD_DDSPERF=OFF \
  -DENABLE_SSL=ON \
  -DENABLE_SHM=OFF \
  -DENABLE_SECURITY=OFF \
  -DENABLE_LIFESPAN=ON \
  -DENABLE_DEADLINE_MISSED=ON \
  -DENABLE_TYPE_DISCOVERY=ON \
  -DENABLE_TOPIC_DISCOVERY=ON \
  -DENABLE_SOURCE_SPECIFIC_MULTICAST=ON \
  -DENABLE_IPV6=OFF \
  ..
cmake --build . --parallel
cmake --build . --target install
cd ..

# Cleanup
rm -rf build

cd /opt
