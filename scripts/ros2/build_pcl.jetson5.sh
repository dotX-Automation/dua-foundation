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
  libopenni-dev \
  libqhull-dev \
  libusb-1.0-0 \
  libusb-1.0-0-dev

# Download and uncompress PCL sources
cd /tmp
wget "https://github.com/PointCloudLibrary/pcl/archive/refs/tags/pcl-$PCL_VERSION.tar.gz"
tar xvf "pcl-$PCL_VERSION.tar.gz"
cd "pcl-pcl-$PCL_VERSION"

# Configure and build PCL
# NOTES
# - This configuration enables all modules except for visualization ones; this
#   implies that every module that also includes a visualizer application
#   must be excluded. This choice is motivated by the intended use of the
#   target platform.
# - This configuration also enables CUDA and GPU support so it can be applied
#   only to platforms that support these features.
# - @robmasocco We suppress a pesky warning from NVCC that is triggered by Eigen
#   code and its use of attributes.
# - @robmasocco The following modules are currently disabled due to incompatibilities
#   with the Thrust library provided in the JetPack environment. This disables
#   additional gpu_* modules that depend on them, depending on the version.
#   - gpu_octree
#   - gpu_surface
# - @robmasocco The following modules are currently disabled due to their use of
#   textures which was removed in CUDA 12.
#   - gpu_kinfu
#   - gpu_kinfu_large_scale
mkdir build
cd build
cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/usr/local \
  -DCMAKE_CUDA_FLAGS="-diag-suppress 20012" \
  -DPCL_SHARED_LIBS=ON \
  -DWITH_VTK=OFF \
  -DBUILD_2d=ON \
  -DBUILD_CUDA=ON \
  -DBUILD_GPU=ON \
  -DBUILD_TESTS=OFF \
  -DBUILD_apps=OFF \
  -DBUILD_common=ON \
  -DBUILD_cuda_apps=OFF \
  -DBUILD_cuda_common=ON \
  -DBUILD_cuda_features=ON \
  -DBUILD_cuda_io=ON \
  -DBUILD_cuda_sample_consensus=ON \
  -DBUILD_cuda_segmentation=ON \
  -DBUILD_examples=OFF \
  -DBUILD_features=ON \
  -DBUILD_filters=ON \
  -DBUILD_geometry=ON \
  -DBUILD_global_tests=OFF \
  -DBUILD_gpu_containers=ON \
  -DBUILD_gpu_features=ON \
  -DBUILD_gpu_kinfu=OFF \
  -DBUILD_gpu_kinfu_large_scale=OFF \
  -DBUILD_gpu_octree=OFF \
  -DBUILD_gpu_people=OFF \
  -DBUILD_gpu_segmentation=ON \
  -DBUILD_gpu_surface=OFF \
  -DBUILD_gpu_tracking=ON \
  -DBUILD_gpu_utils=ON \
  -DBUILD_io=ON \
  -DBUILD_kdtree=ON \
  -DBUILD_keypoints=ON \
  -DBUILD_ml=ON \
  -DBUILD_octree=ON \
  -DBUILD_outofcore=OFF \
  -DBUILD_people=OFF \
  -DBUILD_recognition=ON \
  -DBUILD_registration=ON \
  -DBUILD_sample_consensus=ON \
  -DBUILD_search=ON \
  -DBUILD_segmentation=ON \
  -DBUILD_simulation=OFF \
  -DBUILD_stereo=ON \
  -DBUILD_surface=ON \
  -DBUILD_surface_on_nurbs=OFF \
  -DBUILD_tools=OFF \
  -DBUILD_tracking=ON \
  -DBUILD_visualization=OFF \
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
