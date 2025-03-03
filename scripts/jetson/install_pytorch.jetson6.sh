#!/bin/sh

# PyTorch build script for JetPack 6.
#
# Roberto Masocco <r.masocco@dotxautomation.com>
#
# February 21, 2025

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

#! This script installs a version of PyTorch that is compatible with the
#! JetPack version installed in the jetson6 target.

set -e

# Install dependencies
apt-get update
apt-get install -y --no-install-recommends \
  libavcodec-dev \
  libavformat-dev \
  libjpeg-dev \
  libpython3-dev \
  libswscale-dev \
  zlib1g-dev

# Install bazel
#! @robmasocco Deactivated for now, see below.
# wget -v https://github.com/bazelbuild/bazelisk/releases/download/v1.20.0/bazelisk-linux-arm64
# mv bazelisk-linux-arm64 /usr/bin/bazel
# chmod a+x /usr/bin/bazel

# Install PyTorch from Nvidia wheel
# Ref.: https://docs.nvidia.com/deeplearning/frameworks/install-pytorch-jetson-platform/index.html
# Compatibility matrix: https://docs.nvidia.com/deeplearning/frameworks/install-pytorch-jetson-platform-release-notes/pytorch-jetson-rel.html#pytorch-jetson-rel
TORCH_INSTALL=https://developer.download.nvidia.com/compute/redist/jp/v61/pytorch/torch-2.5.0a0+872d972e41.nv24.08.17622132-cp310-cp310-linux_aarch64.whl
pip install --no-cache $TORCH_INSTALL

# Build TorchVision from source
# Ref.: https://forums.developer.nvidia.com/t/pytorch-and-torchvision-on-jetson-orin/247818/2
cd /opt
export BUILD_VERSION=0.20.0
export CUDA_HOME=/usr/local/cuda-12.6
export FORCE_CUDA=1
export BUILD_CUDA_SOURCES=1
export TORCH_CUDA_ARCH_LIST=8.7
git clone --branch "v$BUILD_VERSION" https://github.com/pytorch/vision torchvision
cd torchvision
python3 setup.py install

# Build and install Torch-TensorRT
# Ref.: https://pytorch.org/TensorRT/getting_started/jetpack.html
# NOTES
# - We skip dependencies steps because they are already installed in the steps up to this one.
# - The branch must be aligned to the PyTorch version installed.
#! @robmasocco This currently does not work for unexpected reasons.
#! It appears that some symbols are missing from the PyTorch C++ libraries.
#! Weird, because the torch-tensorrt instructions specifically mention that version.
#! I am keeping this here for now as reference, hoping that it will work in the future.
# cd /opt
# git clone --branch "release/2.5" --recursive https://github.com/pytorch/TensorRT.git
# cd TensorRT
# cuda_version=$(nvcc --version | grep Cuda | grep release | cut -d ',' -f 2 | sed -e 's/ release //g')
# export TORCH_INSTALL_PATH=$(python -c "import torch, os; print(os.path.dirname(torch.__file__))")
# export SITE_PACKAGE_PATH=$(dirname "$TORCH_INSTALL_PATH")
# export CUDA_HOME=/usr/local/cuda-${cuda_version}/
# cat toolchains/jp_workspaces/MODULE.bazel.tmpl | envsubst > MODULE.bazel
# bazel clean --expunge
# python setup.py install
# rm -rf /opt/TensorRT

# Cleanup
rm -rf /opt/torchvision
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*/apt/lists/*
