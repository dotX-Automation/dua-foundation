#!/bin/sh

# Gazebo simulator installation script.
#
# Roberto Masocco <r.masocco@dotxautomation.com>
#
# February 12, 2025

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

# Get the requested Gazebo version
GAZEBO_VERSION="${1-}"
if [ -z "$GAZEBO_VERSION" ]; then
  echo "No Gazebo version version specified"
  exit 1
fi

# Get the requested ROS 2 distribution
ROS_DISTRO="${2-}"
if [ -z "$ROS_DISTRO" ]; then
  echo "No ROS 2 distribution specified"
  exit 1
fi

# Configure Gazebo repository
curl https://packages.osrfoundation.org/gazebo.gpg --output /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable noble main" | tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null

# Install Gazebo and related components
apt-get update
apt-get install -y --no-install-recommends \
  gz-$GAZEBO_VERSION \
  ros-$ROS_DISTRO-ros-gz

# Cleanup
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*/apt/lists/*
