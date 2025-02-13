#!/bin/sh

# OpenCV installation script.
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

# Get the requested OpenCV version
OPENCV_VERSION="${1-}"

# Clone OpenCV and OpenCV contrib
git clone --single-branch --depth 1 \
  --branch "$OPENCV_VERSION" \
  https://github.com/opencv/opencv.git \
  /opt/opencv
git clone --single-branch --depth 1 \
  --branch "$OPENCV_VERSION" \
  https://github.com/opencv/opencv_contrib.git \
  /opt/opencv_contrib

cd /opt/opencv
mkdir build
cd build

# Configure OpenCV build for the requested target
cmake \
  -D CMAKE_BUILD_TYPE=RELEASE \
  -D CMAKE_INSTALL_PREFIX=/usr/local \
  -D CMAKE_C_FLAGS="-mcpu=native" \
  -D CMAKE_CXX_FLAGS="-mcpu=native" \
  -D EIGEN_INCLUDE_PATH=/usr/local/include/eigen3 \
  -D OPENCV_EXTRA_MODULES_PATH=/opt/opencv_contrib/modules \
  -D OPENCV_GENERATE_PKGCONFIG=ON \
  -D OPENCV_ENABLE_NONFREE=ON \
  -D OPENCV_ENABLE_MEMALIGN=ON \
  -D CPU_BASELINE=NEON \
  -D WITH_TBB=OFF \
  -D WITH_PTHREADS=ON \
  -D WITH_OPENMP=ON \
  -D WITH_EIGEN=ON \
  -D WITH_V4L=ON \
  -D WITH_OPENCL=ON \
  -D WITH_QT=OFF \
  -D ENABLE_FAST_MATH=OFF \
  -D ENABLE_NEON=ON \
  -D ENABLE_PRECOMPILED_HEADERS=OFF \
  -D BUILD_SHARED_LIBS=ON \
  -D BUILD_TBB=OFF \
  -D BUILD_EXAMPLES=OFF \
  -D BUILD_TESTS=OFF \
  -D BUILD_PERF_TESTS=OFF \
  -D BUILD_opencv_python2=OFF \
  -D BUILD_opencv_python3=ON \
  -D INSTALL_PYTHON_EXAMPLES=OFF \
  -D INSTALL_C_EXAMPLES=OFF \
  -D PYTHON3_EXECUTABLE=$(which python3) \
  -D PYTHON_DEFAULT_EXECUTABLE=$(which python3) \
  -D PYTHON3_INCLUDE_PATH=$(python3 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
  -D PYTHON3_NUMPY_INCLUDE_DIRS=$(python3 -c "import numpy; print(numpy.get_include())") \
  -D PYTHON3_LIBRARY=$(python3 -c "import distutils.sysconfig as sysconfig; import os; print(os.path.join(sysconfig.get_config_var('LIBDIR'), sysconfig.get_config_var('LDLIBRARY')))") \
  ..

# Build and install
make -j$(nproc --all)
make install
ldconfig

# Cleanup
cd ..
rm -rf build
