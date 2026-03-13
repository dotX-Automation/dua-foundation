#!/bin/sh

# Stage 2 script for armv8-dev.
#
# Roberto Masocco <r.masocco@dotxautomation.com>
#
# March 13, 2026

# Copyright 2026 dotX Automation s.r.l.
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

# Source new Python virtual environment
. /opt/dua-venv/bin/activate

# Build and install Eigen
cd /opt
/opt/scripts/build_eigen.sh armv8-dev 3.4.0
chgrp internal /opt/scripts/build_eigen.sh
chmod g+rwx /opt/scripts/build_eigen.sh
cd /root

# Build and install OpenCV
cd /opt
/opt/scripts/build_opencv.sh armv8-dev 4.11.0
chgrp internal /opt/scripts/build_opencv.sh
chmod g+rwx /opt/scripts/build_opencv.sh
cd /root

# Install DDS implementations:
# - Fast DDS
# - Cyclone DDS
# NOTES
# - Only C/C++ libraries and support is installed.
# - The versions are fixed to the closest ones supported by ROS 2 Jazzy (below).
# - None of these installations goes to system paths, they remain confined
#   within subdirectories of /opt/dds; see the scripts for details.
#   In case you would like to use these libraries in your projects, you
#   should configure CMake or whatever you use accordingly.
#   This is to enable development with standalone DDS implementations while
#   avoiding to create conflicts with the ROS 2 installation.
cd /opt
/opt/scripts/install_dds.sh armv8-dev 2.14.5 0.10.5
chgrp internal /opt/scripts/install_dds.sh
chmod g+rwx /opt/scripts/install_dds.sh
chgrp -R internal /opt/dds
chmod -R g+rw /opt/dds
cd /root

# Install Zenoh
cd /opt
/opt/scripts/install_zenoh.sh armv8-dev 1.7.1
chgrp internal /opt/scripts/install_zenoh.sh
chmod g+rwx /opt/scripts/install_zenoh.sh
cd /root
