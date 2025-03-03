#!/bin/sh

# Eigen installation script.
#
# Roberto Masocco <r.masocco@dotxautomation.com>
#
# February 10, 2025

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

# Get requested Eigen version
EIGEN_VERSION="${1-}"

# Clone and build Eigen
git clone --single-branch --depth 1 \
  --branch "$EIGEN_VERSION" \
  https://gitlab.com/libeigen/eigen.git \
  /opt/eigen
cd /opt/eigen
mkdir build
cd build
cmake \
  -DCMAKE_INSTALL_PREFIX=/usr/local \
  -DEIGEN_BUILD_BLAS=OFF \
  -DEIGEN_BUILD_LAPACK=OFF \
  -DEIGEN_BUILD_DEMOS=OFF \
  -DEIGEN_BUILD_CMAKE_PACKAGE=ON \
  ..

# Install Eigen
make install

# @robmasocco Somehow this file is forgotten
if [ ! -f /usr/local/share/eigen3/cmake/UseEigen3.cmake ]; then
  cp ../cmake/UseEigen3.cmake /usr/local/share/eigen3/cmake/UseEigen3.cmake
  echo "Copied missing UseEigen3.cmake"
fi

# Cleanup
cd ..
rm -rf build
