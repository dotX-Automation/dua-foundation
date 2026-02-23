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

# Remove Python 3.9 if present
apt-get purge -y python3.9 libpython3.9* || echo "python3.9 not found, skipping removal"

# Build ROS 2 Jazzy Jalisco from source
# The procedure is not obvious, so here is a brief explanation.
# 1. Create a workspace.
# 2. Clone the repos file, containing the default plus some extras.
# 3. Initialize rosdep.
# 4. Update rosdep.
# 5. Install dependencies via rosdep (excluding some stuff that we know we have available).
# 6. Build the workspace (ignoring some unnecessary packages that still get cloned).
# 7. Remove build and log files.
# Step 5 requires caution: to avoid installing duplicated versions of many packages,
# as well as to ensure that the preinstalled versions are found and used, we
# need to specify a list of "rosdep keys" exclude, corresponding to those
# packages that have been already installed by either apt or pip.
# This requires knowledge of the previous build steps, as well as a cross-referencing
# work with the rosdep keys database. The key database is built upon the following
# two files, for system and Python packages respectively.
# - https://github.com/ros/rosdistro/blob/jazzy/2025-02-10/rosdep/base.yaml
# - https://github.com/ros/rosdistro/blob/jazzy/2025-02-10/rosdep/python.yaml
# Step 6 highly depends on the platform and build environment.
# In this case, we need to do the following.
# - Ensure that the Python 3.8 environment is found by CMake (it's the one
#   preinstalled by Nvidia and extended by dua-venv.
# - Ensure that a compatible version of the following libraries is installed
#   and directly pointed to by CMake.
#   - OpenCV
#   - PCL
#   - Eigen3
# - Disable tracetools support since lttng version available in Ubuntu 20.04 is
#   too old and not compatible with the ROS 2 version we are building.
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
  --skip-keys="cargo eigen fastcdr flake8 flake8-blind-except flake8-builtins flake8-class-newline flake8-comprehensions flake8-deprecated flake8-docstrings flake8-import-order flake8-quotes libeigen3-dev libopencv-core libopencv-dev libopencv-contrib-dev libopencv-highgui libopencv-imgcodecs libopencv-imgproc libopencv-imgproc-dev libopencv-videoio libpcl-all libpcl-all-dev libpcl-apps libpcl-common libpcl-features libpcl-filters libpcl-io libpcl-kdtree libpcl-keypoints libpcl-ml libpcl-octree libpcl-outofcore libpcl-people libpcl-recognition libpcl-registration libpcl-sample-consensus libpcl-search libpcl-segmentation libpcl-stereo libpcl-surface libpcl-tracking libpcl-visualization libstd-rust-1.75 libstd-rust-dev opencv2 opencv3 python-opencv python_qt_binding python3-opencv python3-cv-bridge python3-flake8 python3-matplotlib python3-matplotlib-test python3-numpy python3-opencv python3-pyparsing python3-pytest python3-pytest-cov python3-pytest-timeout python3-setuptools python3-yaml python3-argcomplete python3-autopep8 python3-catkin-pkg python3-catkin-pkg-modules python3-colcon-argcomplete python3-colcon-common-extensions python3-colcon-core python3-colcon-library-path python3-colcon-mixin python3-colcon-notification python3-colcon-output python3-colcon-package-information python3-colcon-package-selection python3-colcon-parallel-executor python3-colcon-pkg-config python3-colcon-python-setup-py python3-colcon-recursive-crawl python3-colcon-runtime-dependencies python3-colcon-test-result python3-coverage python3-empy python3-flake8 python3-flake8-builtins python3-flake8-comprehensions python3-flake8-docstrings python3-flake8-import-order python3-flake8-quotes python3-importlib-metadata python3-importlib-resources python3-lark python3-lark-parser python3-mock python3-mypy python3-nose python3-packaging python3-pep8 python3-pydocstyle python3-pyparsing python3-pyflakes python3-pygraphviz python3-pkg-resources python3-psutil python3-pytest-mock python3-requests python3-rosdep-modules python3-rospkg python3-rospkg-modules python3-sphinx python3-sphinx-rtd-theme python3-termcolor python3-urllib3 python3-vcstool python-qt-binding rti-connext-dds-6.0.1 rustc rviz2 rviz_common rviz_default_plugins rviz_rendering urdfdom_headers"
colcon build \
  --merge-install \
  --cmake-args \
    -DCMAKE_BUILD_TYPE=Release \
    -DTRACETOOLS_DISABLED=ON \
    -DPython3_EXECUTABLE=$(which python3) \
    -DPython3_LIBRARY=$(python3 -c "import sysconfig; print(sysconfig.get_config_var('LIBPL') + '/' + sysconfig.get_config_var('LDLIBRARY'))") \
    -DPython3_INCLUDE_DIR=$(python3 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
    -DOpenCV_DIR=/usr/local/lib/cmake/opencv4 \
    -DPCL_DIR=/usr/local/share/pcl-1.14 \
    -DEigen3_DIR=/usr/local/share/eigen3/cmake \
  --ament-cmake-args \
    -DCMAKE_BUILD_TYPE=Release \
    -DTRACETOOLS_DISABLED=ON \
    -DPython3_EXECUTABLE=$(which python3) \
    -DPython3_LIBRARY=$(python3 -c "import sysconfig; print(sysconfig.get_config_var('LIBPL') + '/' + sysconfig.get_config_var('LDLIBRARY'))") \
    -DPython3_INCLUDE_DIR=$(python3 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
    -DOpenCV_DIR=/usr/local/lib/cmake/opencv4 \
    -DPCL_DIR=/usr/local/share/pcl-1.14 \
    -DEigen3_DIR=/usr/local/share/eigen3/cmake \
  --packages-ignore joint_state_publisher_gui lttngpy vision_msgs_rviz_plugins

# Copy rmw_zenoh configuration files
mkdir -p /etc/zenoh/rmw
cp /opt/ros/jazzy/install/share/rmw_zenoh_cpp/config/DEFAULT_RMW_ZENOH_ROUTER_CONFIG.json5 /etc/zenoh/rmw/DEFAULT_RMW_ZENOH_ROUTER_CONFIG.json5
cp /opt/ros/jazzy/install/share/rmw_zenoh_cpp/config/DEFAULT_RMW_ZENOH_SESSION_CONFIG.json5 /etc/zenoh/rmw/DEFAULT_RMW_ZENOH_SESSION_CONFIG.json5
chgrp -R internal /etc/zenoh
chmod -R g+rw /etc/zenoh

# Fix typing issues
# NOTES:
# - JetPack 5 comes with Python 3.8, but Jazzy requires typing extensions which
#   exist only for Python 3.9 and above.
# - Since we cannot upgrade the system Python unless we want to break the image
#   and everything it contains, we modify the code to make it compliant with
#   Python 3.8.
sed -i '/^from typing import.*Optional/s/import/import List,/' /opt/ros/jazzy/install/lib/python3.8/site-packages/ros2topic/api/__init__.py
sed -i '165s/\blist\[str\]/List[str]/' /opt/ros/jazzy/install/lib/python3.8/site-packages/ros2topic/api/__init__.py

# Build and install serial library
cd /opt
git clone --single-branch --branch 'main' --depth 1 https://github.com/dotX-Automation/serial.git
cd serial
make
make install
ldconfig
cd /opt
rm -rf serial

# Cleanup
rm -rf build log src
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*/apt/lists/*
