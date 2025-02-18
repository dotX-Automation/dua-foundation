#!/bin/sh

# ROS 2 source build script.
#
# Roberto Masocco <r.masocco@dotxautomation.com>
#
# February 16, 2025

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

# This script assumes the following.
# - The relevant Python environment has already been sourced.
# - All necessary files have been mounted in specific places.

#! This script builds and installs ROS 2 Jazzy Jalisco.

set -e

# Get repos file
REPOS_FILE=$1
if [ -z "$REPOS_FILE" ]; then
  echo "Usage: $0 <repos file>"
  exit 1
fi

# Configure ROS 2 repository
apt-get update
apt-get install -y --no-install-recommends ca-certificates curl
curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null

# Install ROS development tools
# NOTES
# - This will install many Python packages from apt. Since some are not available
#   in the index, they will be installed like this in the system environment.
# - There are also some other libraries that some packages depend on but that are
#   inexplicably not installed by rosdep.
apt-get update
apt-get install -y --no-install-recommends \
  libacl1-dev \
  libbullet-dev \
  libflann-dev \
  libgps-dev \
  liblttng-ctl-dev \
  liblttng-ust-dev \
  libusb-1.0-0 \
  libusb-1.0-0-dev \
  lttng-tools \
  python3-lttng \
  ros-dev-tools

# Create pkg-config file for lttng-ctl, which is somehow missing from the
# release package
mkdir -p /usr/lib/aarch64-linux-gnu/pkgconfig
tee /usr/lib/aarch64-linux-gnu/pkgconfig/lttng-ctl.pc << 'EOF'
prefix=/usr
exec_prefix=${prefix}
libdir=${prefix}/lib/aarch64-linux-gnu
includedir=${prefix}/include

Name: lttng-ctl
Description: LTTng control and utility library
Version: 2.11.2
Requires:
Libs: -L${libdir} -llttng-ctl
Cflags: -I${includedir}
EOF

# Build and install PCL 1.14.0
wget https://github.com/PointCloudLibrary/pcl/archive/refs/tags/pcl-1.14.0.tar.gz
tar xvf pcl-1.14.0.tar.gz
cd pcl-pcl-1.14.0
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j$(nproc --all)
make install
ldconfig
cd ../..
rm -rf pcl-1.14.0.tar.gz pcl-pcl-1.14.0

# Remove Python 3.9 if present
apt-get purge -y python3.9 libpython3.9* || echo "python3.9 not found, skipping removal"

# Build ROS 2 Jazzy Jalisco from source
# The procedure is not obvious, so here is a brief explanation.
# 1. Create a workspace.
# 2. Clone the repos file, containing the default plus some extras.
# 3. Initialize rosdep.
# 4. Update rosdep.
# 5. Install dependencies via rosdep (excluding some stuff that we know we have available).
# 6. Build the workspace.
# 7. Remove build and log files.
# Step 6 highly depends on the platform and build environment.
# In this case, we need to ensure the following.
# - Having installed a version of OpenCV that is compatible with this codebase.
# - Ensure that the Python 3.8.0 environment is found by CMake (it's the one
#   preinstalled by Nvidia and extended by the DUA one).
# - Ensure that the desired OpenCV installation is found by CMake.
mkdir -p /opt/ros/jazzy/src
cd /opt/ros/jazzy
vcs import --input $REPOS_FILE src
rosdep init
rosdep update --rosdistro=jazzy
rosdep install \
  --rosdistro=jazzy \
  --from-paths src \
  --ignore-src \
  -y \
  --skip-keys="fastcdr libopencv-dev libopencv-contrib-dev libopencv-imgproc-dev python3-matplotlib python-opencv python3-opencv python_qt_binding rti-connext-dds-6.0.1 rviz2 rviz_common rviz_default_plugins rviz_rendering urdfdom_headers"
colcon build \
  --merge-install \
  --cmake-args \
    -DCMAKE_BUILD_TYPE=Release \
    -DTRACETOOLS_DISABLED=ON \
    -DPython3_EXECUTABLE=$(which python3) \
    -DPython3_LIBRARY=$(python3 -c "import sysconfig; print(sysconfig.get_config_var('LIBPL') + '/' + sysconfig.get_config_var('LDLIBRARY'))") \
    -DPython3_INCLUDE_DIR=$(python3 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
    -DOpenCV_DIR=/usr/local/lib/cmake/opencv4 \
  --ament-cmake-args \
    -DCMAKE_BUILD_TYPE=Release \
    -DTRACETOOLS_DISABLED=ON \
    -DPython3_EXECUTABLE=$(which python3) \
    -DPython3_LIBRARY=$(python3 -c "import sysconfig; print(sysconfig.get_config_var('LIBPL') + '/' + sysconfig.get_config_var('LDLIBRARY'))") \
    -DPython3_INCLUDE_DIR=$(python3 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
    -DOpenCV_DIR=/usr/local/lib/cmake/opencv4 \
  --packages-ignore joint_state_publisher_gui lttngpy vision_msgs_rviz_plugins

# Cleanup
rm -rf build log src
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*/apt/lists/*
