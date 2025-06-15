#!/bin/sh

# ROS 2 installation script.
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

# Get the requested ROS 2 version
ROS_DISTRO="${1-}"
if [ -z "$ROS_DISTRO" ]; then
  echo "No ROS 2 version specified"
  exit 1
fi

# Get the requested rmw_zenoh commit hash
RMW_ZENOH_COMMIT="${2-}"
if [ -z "$RMW_ZENOH_COMMIT" ]; then
  echo "No rmw_zenoh commit hash specified"
  exit 1
fi

# Configure ROS 2 repository
ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F "tag_name" | awk -F\" '{print $4}')
curl -L -o /tmp/ros2-apt-source.deb "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo noble)_all.deb"
apt install -y /tmp/ros2-apt-source.deb
rm /tmp/ros2-apt-source.deb

# Install ROS 2 and related components
apt-get update
apt-get install -y --no-install-recommends \
  ros-dev-tools \
  ros-$ROS_DISTRO-actuator-msgs \
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
  ros-$ROS_DISTRO-joint-state-publisher \
  ros-$ROS_DISTRO-laser-filters \
  ros-$ROS_DISTRO-launch-testing \
  ros-$ROS_DISTRO-launch-testing-ament-cmake \
  ros-$ROS_DISTRO-launch-testing-ros \
  ros-$ROS_DISTRO-perception \
  ros-$ROS_DISTRO-perception-pcl \
  ros-$ROS_DISTRO-rmw-cyclonedds-cpp \
  ros-$ROS_DISTRO-rmw-fastrtps-cpp \
  ros-$ROS_DISTRO-robot-state-publisher \
  ros-$ROS_DISTRO-ros-base \
  ros-$ROS_DISTRO-rosidl-generator-dds-idl \
  ros-$ROS_DISTRO-vision-msgs \
  ros-$ROS_DISTRO-vision-opencv \
  ros-$ROS_DISTRO-xacro

# Build rmw_zenoh from source
. /opt/ros/$ROS_DISTRO/setup.sh
cd /opt/ros
mkdir -p zenoh/src
cd zenoh/src
git clone -b $ROS_DISTRO https://github.com/ament/ament_cmake.git
git clone -b $ROS_DISTRO https://github.com/ros2/rmw_zenoh.git
cd rmw_zenoh
git checkout $RMW_ZENOH_COMMIT
cd /opt/ros/zenoh
colcon build --merge-install
printf ". /opt/ros/zenoh/install/setup.bash\n" >> /opt/ros/$ROS_DISTRO/setup.bash
printf ". /opt/ros/zenoh/install/setup.zsh\n" >> /opt/ros/$ROS_DISTRO/setup.zsh
printf ". /opt/ros/zenoh/install/setup.sh\n" >> /opt/ros/$ROS_DISTRO/setup.sh

# Install rmw_zenoh sample configuration files
mkdir -p /etc/zenoh/rmw
cp /opt/ros/zenoh/install/share/rmw_zenoh_cpp/config/DEFAULT_RMW_ZENOH_ROUTER_CONFIG.json5 /etc/zenoh/rmw/DEFAULT_RMW_ZENOH_ROUTER_CONFIG.json5
cp /opt/ros/zenoh/install/share/rmw_zenoh_cpp/config/DEFAULT_RMW_ZENOH_SESSION_CONFIG.json5 /etc/zenoh/rmw/DEFAULT_RMW_ZENOH_SESSION_CONFIG.json5
chgrp -R internal /etc/zenoh
chmod -R g+rw /etc/zenoh

# Cleanup
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*/apt/lists/*
