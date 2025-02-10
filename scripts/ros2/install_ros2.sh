#!/bin/sh

# ROS 2 installation script.
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

# Get the requested ROS 2 version
ROS_DISTRO="${1-}"
if [ -z "$ROS_DISTRO" ]; then
  echo "No ROS 2 version specified"
  exit 1
fi

# Get the requested target
TARGET="${2-}"
if [ -z "$TARGET" ]; then
  echo "No target specified"
  exit 1
fi
if [ "$TARGET" != "x86-base" ] &&
  [ "$TARGET" != "x86-dev" ] &&
  [ "$TARGET" != "x86-cudev" ] &&
  [ "$TARGET" != "armv8-base" ] &&
  [ "$TARGET" != "armv8-dev" ]; then
  echo "Invalid target: $TARGET"
  exit 1
fi

echo "Installing ROS 2 $ROS_DISTRO for target $TARGET"

# Configure ROS 2 repository
curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu noble main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null

# Install ROS 2 and related components
if [ "$TARGET" = "x86-base" ]; then
  apt-get update
  apt-get install -y --no-install-recommends \
    python3-colcon-argcomplete \
    python3-colcon-common-extensions \
    python3-colcon-mixin \
    python3-rosdep \
    ros-dev-tools \
    ros-$ROS_DISTRO-ament-lint \
    ros-$ROS_DISTRO-angles \
    ros-$ROS_DISTRO-cv-bridge \
    ros-$ROS_DISTRO-diagnostic-msgs \
    ros-$ROS_DISTRO-diagnostic-updater \
    ros-$ROS_DISTRO-eigen3-cmake-module \
    ros-$ROS_DISTRO-filters \
    ros-$ROS_DISTRO-geographic-msgs \
    ros-$ROS_DISTRO-geographic-info \
    ros-$ROS_DISTRO-gps-msgs \
    ros-$ROS_DISTRO-gps-tools \
    ros-$ROS_DISTRO-gps-umd \
    ros-$ROS_DISTRO-gpsd-client \
    ros-$ROS_DISTRO-image-common \
    ros-$ROS_DISTRO-image-geometry \
    ros-$ROS_DISTRO-image-pipeline \
    ros-$ROS_DISTRO-image-transport \
    ros-$ROS_DISTRO-image-transport-plugins \
    ros-$ROS_DISTRO-laser-filters \
    ros-$ROS_DISTRO-launch-testing \
    ros-$ROS_DISTRO-launch-testing-ament-cmake \
    ros-$ROS_DISTRO-launch-testing-ros \
    ros-$ROS_DISTRO-perception-pcl \
    ros-$ROS_DISTRO-rmw-cyclonedds-cpp \
    ros-$ROS_DISTRO-rmw-fastrtps-cpp \
    ros-$ROS_DISTRO-rmw-zenoh-cpp \
    ros-$ROS_DISTRO-ros-base \
    ros-$ROS_DISTRO-vision-msgs \
    ros-$ROS_DISTRO-vision-opencv \
    ros-$ROS_DISTRO-xacro

  wget -O /usr/local/bin/zenoh-bridge-ros2dds http://160.80.97.139:8087/Software/DUA/zenoh-plugin-ros2dds-1.2.1-x86_64-unknown-linux-gnu-standalone/zenoh-bridge-ros2dds
  chmod a+x /usr/local/bin/zenoh-bridge-ros2dds
else
  # Should not happen at this point
  echo "Invalid target: $TARGET"
  exit 1
fi

# Cleanup
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*/apt/lists/*
