#!/bin/sh

# Eigen installation script.
#
# Roberto Masocco <r.masocco@dotxautomation.com>
#
# February 10, 2025

# Copyright 2024 dotX Automation s.r.l.
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

# Get requested Eigen version
EIGEN_VERSION="${1-}"

# Clone and build Eigen
git clone --single-branch --depth 1 \
  --branch "$EIGEN_VERSION" \
  https://gitlab.com/libeigen/eigen.git
cd eigen
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/usr/local ..
make -j$(nproc --all)

# Install Eigen
make install

# Cleanup
cd ..
rm -rf build
