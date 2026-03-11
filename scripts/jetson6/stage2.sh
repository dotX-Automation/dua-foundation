#!/bin/sh

# Stage 2 script for jetson6.
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

# Configure language and locale
locale-gen en_US.UTF-8
update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

# Install Rust toolchain
cd /opt
/opt/scripts/install_rust.sh jetson6 1.85.0
chgrp internal /opt/scripts/install_rust.sh
chmod g+rwx /opt/scripts/install_rust.sh
chgrp -R internal /opt/rust
chmod -R g+rw /opt/rust
cd /root

# Install nlohmann/json C++ library
cd /opt
/opt/scripts/install_nlohmann_json.sh jetson6 3.12.0
chgrp internal /opt/scripts/install_nlohmann_json.sh
chmod g+rwx /opt/scripts/install_nlohmann_json.sh
cd /root

# Build and install Eigen
cd /opt
/opt/scripts/build_eigen.sh jetson6 3.4
chgrp internal /opt/scripts/build_eigen.sh
chmod g+rwx /opt/scripts/build_eigen.sh
cd /root

# Build and install OpenCV
cd /opt
/opt/scripts/build_opencv.sh jetson6 4.11.0
chgrp internal /opt/scripts/build_opencv.sh
chmod g+rwx /opt/scripts/build_opencv.sh
cd /root

# Build and install PyTorch
cd /opt
/opt/scripts/install_pytorch.sh jetson6
chgrp internal /opt/scripts/install_pytorch.sh
chmod g+rwx /opt/scripts/install_pytorch.sh
cd /root

# Install TensorFlow
cd /opt
/opt/scripts/install_tensorflow.sh jetson6
chgrp internal /opt/scripts/install_tensorflow.sh
chmod g+rwx /opt/scripts/install_tensorflow.sh
cd /root
