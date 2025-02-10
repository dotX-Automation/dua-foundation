#!/bin/sh

# dua-utils build script.
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

# Get ROS 2 version as argument
ROS_DISTRO="${1-}"
if [ -z "$ROS_DISTRO" ]; then
  echo "No ROS 2 version specified"
  exit 1
fi

# Clone and build dua-utils
git clone --recursive https://github.com/dotX-Automation/dua-utils.git /opt/ros/dua-utils
cd /opt/ros/dua-utils
. /opt/ros/$ROS_DISTRO/setup.sh
colcon build --merge-install

# Cleanup
rm -rf build log
