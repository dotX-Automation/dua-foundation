#!/bin/sh

# OpenCV installation script.
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

# Get the requested target
TARGET="${1-}"

# Check that the target is valid
if [ -z "$TARGET" ]; then
  echo "No target specified"
  exit 1
fi
if [ "$TARGET" != "x86-base" ] &&
  [ "$TARGET" != "x86-dev" ] &&
  [ "$TARGET" != "x86-cudev" ] &&
  [ "$TARGET" != "jetson5" ] &&
  [ "$TARGET" != "armv8-base" ] &&
  [ "$TARGET" != "armv8-dev" ]; then
  echo "Invalid target: $TARGET"
  exit 1
fi
echo "Building OpenCV for target: $TARGET"

# Clone OpenCV and OpenCV contrib
OPENCV_VERSION="4.11.0"
git clone --single-branch --depth 1 \
  --branch "$OPENCV_VERSION" \
  https://github.com/opencv/opencv.git
git clone --single-branch --depth 1 \
  --branch "$OPENCV_VERSION" \
  https://github.com/opencv/opencv_contrib.git

cd opencv
mkdir build
cd build

# Configure OpenCV build for the requested target
if [ "$TARGET" = "x86-base" ]; then
  cmake \
    -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D EIGEN_INCLUDE_PATH=/usr/local/include/eigen3 \
    -D OPENCV_EXTRA_MODULES_PATH=/opt/opencv_contrib/modules \
    -D OPENCV_GENERATE_PKGCONFIG=ON \
    -D OPENCV_ENABLE_NONFREE=ON \
    -D OPENCV_ENABLE_MEMALIGN=ON \
    -D CPU_BASELINE=SSE4_2 \
    -D CPU_DISPATCH=AVX,AVX2,AVX512_SKX \
    -D WITH_TBB=ON \
    -D WITH_EIGEN=ON \
    -D WITH_V4L=ON \
    -D WITH_QT=OFF \
    -D ENABLE_FAST_MATH=OFF \
    -D BUILD_SHARED_LIBS=ON \
    -D BUILD_TBB=OFF \
    -D BUILD_EXAMPLES=OFF \
    -D BUILD_TESTS=OFF \
    -D BUILD_opencv_python2=OFF \
    -D BUILD_opencv_python3=ON \
    -D INSTALL_PYTHON_EXAMPLES=OFF \
    -D INSTALL_C_EXAMPLES=OFF \
    -D PYTHON3_EXECUTABLE=$(which python3) \
    -D PYTHON_DEFAULT_EXECUTABLE=$(which python3) \
    -D PYTHON3_INCLUDE_PATH=$(python3 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
    -D PYTHON3_NUMPY_INCLUDE_DIRS=$(python3 -c "import numpy; print(numpy.get_include())") \
    -D PYTHON3_LIBRARY=$(python3 -c "import distutils.sysconfig as sysconfig; import os; print(os.path.join(sysconfig.get_config_var('LIBDIR'), sysconfig.get_config_var('LDLIBRARY')))") \
    -D PYTHON3_PACKAGES_PATH=$(python3 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") \
  ..
else
  # Should not happen at this point
  echo "Invalid target: $TARGET"
  exit 1
fi

# Build and install
make -j$(nproc --all)
make install
ldconfig

# Cleanup
cd ..
rm -rf build
