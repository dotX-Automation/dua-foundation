#!/bin/sh

# Stage 3 script for jetson6.
#
# Roberto Masocco <r.masocco@dotxautomation.com>
#
# March 11, 2026

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

# Build and install ONNX Runtime
cd /opt
/opt/scripts/build_onnxruntime.sh jetson6
chgrp internal /opt/scripts/build_onnxruntime.sh
chmod g+rwx /opt/scripts/build_onnxruntime.sh
cd /root

# Install Ultralytics
pip install ultralytics --no-deps
pip install ultralytics-thop

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
/opt/scripts/install_dds.sh jetson6 2.14.5 0.10.5
chgrp internal /opt/scripts/install_dds.sh
chmod g+rwx /opt/scripts/install_dds.sh
chgrp -R internal /opt/dds
chmod -R g+rw /opt/dds
cd /root

# Install Zenoh
cd /opt
/opt/scripts/install_zenoh.sh jetson6 1.7.1
chgrp internal /opt/scripts/install_zenoh.sh
chmod g+rwx /opt/scripts/install_zenoh.sh
cd /root

# Build and install PCL
cd /opt
/opt/scripts/build_pcl.sh jetson6 1.14.0
chgrp internal /opt/scripts/build_pcl.sh
chmod g+rwx /opt/scripts/build_pcl.sh
cd /root
