#!/bin/sh

# dua-utils build script.
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

# Install additional dependencies
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
  libzmq3-dev
sudo rm -rf /var/lib/apt/lists/* /var/tmp/*/apt/lists/*

# Parse arguments depending on how many were provided
if [ "$#" -eq 3 ]; then
  # Three arguments: base unit type, ROS 2 version, repos file (explicit)
  BASE_UNIT_TYPE="$1"
  if [ -z "$BASE_UNIT_TYPE" ]; then
    echo "No base unit type specified"
    exit 1
  fi

  ROS_DISTRO="$2"
  if [ -z "$ROS_DISTRO" ]; then
    echo "No ROS 2 version specified"
    exit 1
  fi

  REPOS_FILE="$3"
  if [ -z "$REPOS_FILE" ]; then
    echo "No repos file specified"
    exit 1
  fi
elif [ "$#" -eq 2 ]; then
  # Two arguments: ROS 2 version and repos file; infer the base unit type
  # from the repos file name
  ROS_DISTRO="$1"
  REPOS_FILE="$2"

  case "${REPOS_FILE##*/}" in
    *base*)
      BASE_UNIT_TYPE="base"
      ;;
    *dev*)
      BASE_UNIT_TYPE="dev"
      ;;
    *)
      echo "Cannot infer base unit type from repos file name '$REPOS_FILE'"
      exit 1
      ;;
  esac
else
  echo "Usage: $0 <base_unit_type> <ros_distro> <repos_file> | <ros_distro> <repos_file>"
  exit 1
fi

# Source ROS 2 installation
if [ -f "/opt/ros/$ROS_DISTRO/setup.sh" ]; then
  . /opt/ros/$ROS_DISTRO/setup.sh
elif [ -f "/opt/ros/$ROS_DISTRO/install/setup.sh" ]; then
  . /opt/ros/$ROS_DISTRO/install/setup.sh
else
  echo "ROS 2 version $ROS_DISTRO not found"
  exit 1
fi

# Clone and build dua-utils
mkdir -p /opt/ros/dua-utils/src
cd /opt/ros/dua-utils
vcs import --input $REPOS_FILE src
if [ "$BASE_UNIT_TYPE" = "base" ]; then
  # Thidparty libraries and dependencies
  colcon build --merge-install \
    --ament-cmake-args \
      "-DBTCPP_BUILD_TOOLS=OFF" \
      "-DBTCPP_EXAMPLES=OFF" \
      "-DBTCPP_GROOT_INTERFACE=ON" \
      "-DBTCPP_SHARED_LIBS=ON" \
      "-DBTCPP_SQLITE_LOGGING=ON" \
      "-DBUILD_TESTING=OFF" \
    --packages-up-to \
      behaviortree_cpp

  # Interfaces
  colcon build --merge-install --packages-up-to \
    dua_aircraft_interfaces \
    dua_common_interfaces \
    dua_geometry_interfaces \
    dua_hardware_interfaces \
    dua_mission_interfaces \
    dua_movement_interfaces \
    dua_uxv_interfaces

  # Core libraries
  colcon build --merge-install --packages-up-to \
    dua_app_management \
    dua_cv_bridge \
    dua_math \
    dua_node_cpp \
    dua_node_py \
    dua_pcl \
    dua_qos_cpp \
    dua_qos_py \
    dua_structures_cpp \
    dua_tf_server \
    params_manager_cpp \
    params_manager_py \
    pose_kit \
    simple_actionclient_cpp \
    simple_actionclient_py \
    simple_serviceclient_cpp \
    simple_serviceclient_py

  # Additional libraries
  colcon build --merge-install --packages-up-to \
    dua_behaviortree_cpp \
    dynamic_systems \
    polynomial_kit \
    transitions_ros

  # Nodes
  colcon build --merge-install --packages-up-to \
    dua_ros_topic_tools \
    navsat_converter \
    pose_solver \
    scan_deskewer \
    targets_converter
elif [ "$BASE_UNIT_TYPE" = "dev" ]; then
  # Thidparty libraries and dependencies
  colcon build --merge-install \
    --ament-cmake-args \
      "-DBTCPP_BUILD_TOOLS=OFF" \
      "-DBTCPP_EXAMPLES=OFF" \
      "-DBTCPP_GROOT_INTERFACE=ON" \
      "-DBTCPP_SHARED_LIBS=ON" \
      "-DBTCPP_SQLITE_LOGGING=ON" \
      "-DBUILD_TESTING=OFF" \
    --packages-up-to \
      behaviortree_cpp

  # Interfaces
  colcon build --merge-install --packages-up-to \
    dua_aircraft_interfaces \
    dua_common_interfaces \
    dua_geometry_interfaces \
    dua_hardware_interfaces \
    dua_mission_interfaces \
    dua_movement_interfaces \
    dua_uxv_interfaces

  # Core libraries
  colcon build --merge-install --packages-up-to \
    dua_app_management \
    dua_cv_bridge \
    dua_math \
    dua_node_cpp \
    dua_node_py \
    dua_pcl \
    dua_qos_cpp \
    dua_qos_py \
    dua_structures_cpp \
    dua_tf_server \
    params_manager_cpp \
    params_manager_py \
    pose_kit \
    simple_actionclient_cpp \
    simple_actionclient_py \
    simple_serviceclient_cpp \
    simple_serviceclient_py

  # Additional libraries
  colcon build --merge-install --packages-up-to \
    camera_calibration \
    dua_behaviortree_cpp \
    dua_rviz_plugins \
    dynamic_systems \
    polynomial_kit \
    transitions_ros

  # Nodes
  colcon build --merge-install --packages-up-to \
    dua_ros_topic_tools \
    navsat_converter \
    pose_solver \
    scan_deskewer \
    targets_converter \
    teleop_uxv_joy
else
  echo "Unknown base unit type specified"
  exit 1
fi

# Cleanup
rm -rf build log
