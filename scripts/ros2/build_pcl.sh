#!/bin/sh

# PCL build script.
#
# Roberto Masocco <r.masocco@dotxautomation.com>
#
# February 19, 2025

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

set -e

# Get PCL version as argument
PCL_VERSION=$1
if [ -z "$PCL_VERSION" ]; then
  echo "Usage: $0 <PCL version>"
  exit 1
fi

# Cut out the last .digit from the version
PCL_VERSION_MAJOR=$(echo $PCL_VERSION | cut -d. -f1-2)

# Install dependencies
apt-get update
apt-get install -y --no-install-recommends \
  libflann-dev \
  libqhull-dev \
  libusb-1.0-0 \
  libusb-1.0-0-dev

# Download and uncompress PCL sources
cd /tmp
wget "https://github.com/PointCloudLibrary/pcl/archive/refs/tags/pcl-$PCL_VERSION.tar.gz"
tar xvf "pcl-$PCL_VERSION.tar.gz"
cd "pcl-pcl-$PCL_VERSION"

# Configure and build PCL
mkdir build
cd build
cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/usr/local \
  -DPCL_SHARED_LIBS=ON \
  -DBUILD_common=ON \
  -DBUILD_octree=ON \
  -DBUILD_io=ON \
  -DBUILD_kdtree=ON \
  -DBUILD_search=ON \
  -DBUILD_sample_consensus=ON \
  -DBUILD_filters=ON \
  -DBUILD_2d=ON \
  -DBUILD_features=ON \
  -DBUILD_ml=ON \
  -DBUILD_segmentation=ON \
  -DBUILD_surface=ON \
  -DBUILD_registration=ON \
  -DBUILD_keypoints=ON \
  -DBUILD_tracking=ON \
  -DBUILD_recognition=ON \
  -DBUILD_stereo=ON \
  -DBUILD_outofcore=ON \
  -DBUILD_people=ON \
  -DBUILD_apps=OFF \
  -DBUILD_examples=OFF \
  -DBUILD_tools=OFF \
  -DBUILD_visualization=OFF \
  -DWITH_VTK=OFF \
  -DBUILD_TESTS=OFF \
  ..
make -j$(nproc --all)
make install
ldconfig

# Create symbolic links from versioned to unversioned PCL paths
ln -sf "/usr/local/include/pcl-$PCL_VERSION_MAJOR/pcl" /usr/local/include/pcl

# Cleanup
cd ../..
rm -rf "pcl-$PCL_VERSION.tar.gz" "pcl-pcl-$PCL_VERSION"
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*/apt/lists/*
