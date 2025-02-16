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

#! This script builds and install ROS 2 Jazzy Jalisco.

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
# - There are also Python packages, but they should be installed as part of
#   the Python environment setup.
# - We could simply install ros-dev-tools but to not taint the system environment
#   the many Python packages have been installed in the dua-venv.
apt-get update
apt-get install -y --no-install-recommends \
  libacl1-dev \
  ros-dev-tools

# Build ROS 2 Jazzy Jalisco from source
# The procedure is not obvious, so here is a brief explanation.
# 1.  Create a workspace.
# 2.  Clone the repos file, containing the default plus some extras.
# 3.  Initialize rosdep.
# 4.  Update rosdep.
# 5.  Remove opencv* packets preinstalled in the base image (should be version 4.5.x).
# 6.  Install libopencv-dev (version 4.7.0) which is required for this build.
# 7.  Install dependencies via rosdep (but it can't handle libopencv-dev alone).
# 8.  Reinstall libopencv-dev (version 4.7.0) which gets lost somehow.
# 9.  Build the workspace.
# 10. Remove build and log files.
# Step 9 highly depends on the platform and build environment.
# In this case, we need to ensure the following.
# - Having installed a version of OpenCV that is compatible with this codebase.
# - Ensure that the Python 3.8.0 environment is found by CMake (it's the one preinstalled by Nvidia).
# - Ensure that the desired OpenCV installation is found by CMake.
mkdir -p /opt/ros/jazzy/src
cd /opt/ros/jazzy
vcs import --input $REPOS_FILE src
rosdep init
rosdep update --rosdistro=jazzy
# apt-get update
# apt-get remove -y opencv-dev opencv-libs
# apt-get install -y --no-install-recommends libopencv-dev
rosdep install \
  --rosdistro=jazzy \
  --from-paths src \
  --ignore-src \
  -y \
  --skip-keys="fastcdr libopencv-dev libopencv-contrib-dev libopencv-imgproc-dev python3-matplotlib python-opencv python3-opencv python_qt_binding rti-connext-dds-6.0.1 rviz2 rviz_common rviz_default_plugins rviz_rendering urdfdom_headers"
# apt-get install -y --no-install-recommends libopencv-dev
colcon build \
  --merge-install \
  --cmake-args \
    -DCMAKE_BUILD_TYPE=Release \
    -DPython3_EXECUTABLE=$(which python3) \
    -DPython3_LIBRARY=$(python3 -c "import sysconfig; print(sysconfig.get_config_var('LIBPL') + '/' + sysconfig.get_config_var('LDLIBRARY'))") \
    -DPython3_INCLUDE_DIR=$(python3 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
    -DOpenCV_DIR=/usr/local/lib/cmake/opencv4 \
  --ament-cmake-args \
    -DCMAKE_BUILD_TYPE=Release \
    -DPython3_EXECUTABLE=$(which python3) \
    -DPython3_LIBRARY=$(python3 -c "import sysconfig; print(sysconfig.get_config_var('LIBPL') + '/' + sysconfig.get_config_var('LDLIBRARY'))") \
    -DPython3_INCLUDE_DIR=$(python3 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
    -DOpenCV_DIR=/usr/local/lib/cmake/opencv4 \
  --packages-ignore joint_state_publisher_gui vision_msgs_rviz_plugins

# TODO Check
# Remove matplotlib from apt and reinstall it with pip
# This is necessary to avoid an incompatibility of matplotlib with the extension
# of the Python 3 system environment.
# apt-get remove -y python3-matplotlib
# pip install matplotlib==3.5.0

# TODO Enable
# Cleanup
# rm -rf build log src
# rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*/apt/lists/*
