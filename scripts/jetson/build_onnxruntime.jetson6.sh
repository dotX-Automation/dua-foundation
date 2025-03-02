#!/bin/sh

# ONNX Runtime build script for JetPack 6.
#
# Roberto Masocco <r.masocco@dotxautomation.com>
#
# March 2, 2025

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
# - Nvidia wheels are available at
#   https://developer.download.nvidia.com/compute/redist/jp/

#! This script installs a given version of onnxruntime that must be compatible with:
#! - the JetPack version installed in the current target;
#! - the Python version installed in the current target;
#! - the CUDA version installed in the current target.
#! If adapting to another target, check the build process carefully since you
#! may need to change:
#! - the ONNX Runtime version;
#! - some paths passed to the build script;
#! - the CUDA architecture (CMAKE_CUDA_ARCHITECTURES);
#! - the wheel file name (due to the Python version);
#! - the Eigen path.
#! Refs.:
#! - https://onnxruntime.ai/docs/execution-providers/CUDA-ExecutionProvider.html#build-from-source
#! - https://onnxruntime.ai/docs/build/eps.html#cuda

set -e

# Get version
ORT_VERSION="1.20.1"

# Clone and build ONNX Runtime
git clone \
  --recursive \
  --single-branch \
  --branch "v$ORT_VERSION" \
  https://github.com/microsoft/onnxruntime.git \
  /opt/onnxruntime
cd /opt/onnxruntime
./build.sh \
  --config Release \
  --update \
  --build \
  --parallel \
  --build_wheel \
  --use_tensorrt \
  --cuda_home /usr/local/cuda \
  --cudnn_home /usr/lib/aarch64-linux-gnu \
  --tensorrt_home /usr/lib/python3.10/dist-packages/tensorrt \
  --allow_running_as_root \
  --skip_tests \
  --cmake_extra_defines \
    'CMAKE_CUDA_ARCHITECTURES=87' \
    'onnxruntime_BUILD_UNIT_TESTS=OFF' \
    'onnxruntime_USE_FLASH_ATTENTION=OFF' \
    'onnxruntime_USE_MEMORY_EFFICIENT_ATTENTION=OFF' \
  --use_preinstalled_eigen \
  --eigen_path=/usr/local/include/eigen3
pip install ./build/Linux/Release/dist/onnxruntime_gpu-${ORT_VERSION}-cp310-cp310-linux_aarch64.whl
cd /opt

# Cleanup
rm -rf /opt/onnxruntime
