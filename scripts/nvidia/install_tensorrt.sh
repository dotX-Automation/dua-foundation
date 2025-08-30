#!/bin/sh

# TensorRT installation script.
#
# Roberto Masocco <r.masocco@dotxautomation.com>
#
# August 30, 2025

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

# Get requested TensorRT version
TRT_VERSION="${1-}"

# Get requested architecture
TRT_ARCH="${2-}"

# Configure Nvidia repositories
# NOTES
# - This allows to install TensorRT-related packages with the appropriate CUDA
#   version, since someone had the brilliant idea to put only the latest
#   version in the repo, which is already configured in the  base image.
echo "Package: libnvinfer* libnvonnxparsers*" > /etc/apt/preferences.d/cuda-repository-pin
echo "Pin: version *+cuda12.9*" >> /etc/apt/preferences.d/cuda-repository-pin
echo "Pin-Priority: 1001" >> /etc/apt/preferences.d/cuda-repository-pin
apt-get update

# Download TensorRT packages
wget -q -r -nH --cut-dirs=6 -P /opt/trt http://160.80.97.139:8087/Software/DUA/NVIDIA/TensorRT/${TRT_VERSION}/packages_${TRT_ARCH}/

# Install TensorRT packages
apt-get install -y --no-install-recommends /opt/trt/*.deb
cp /opt/trt/*.gpg /usr/share/keyrings/

# Clean up
rm -rf /opt/trt
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*/apt/lists/*
