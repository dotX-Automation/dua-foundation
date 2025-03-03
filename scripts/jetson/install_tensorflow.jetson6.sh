#!/bin/sh

# TensorFlow script for JetPack 6.
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

#! This script installs a version of TensorFlow that is compatible with the
#! JetPack version installed in the jetson6 target.
#! Ref.: https://docs.nvidia.com/deeplearning/frameworks/install-tf-jetson-platform/index.html

set -e

# Install dependencies
apt-get update
apt-get install -y --no-install-recommends \
  gfortran \
  hdf5-tools \
  libblas-dev \
  libhdf5-dev \
  libhdf5-serial-dev \
  libjpeg8-dev \
  liblapack-dev \
  zip \
  zlib1g-dev

# Install Python dependencies, including Keras
# NOTES
# - These are not all the ones referenced in the official documentation but only
#   those not covered by the basic dua-venv installation.
pip install \
  cython \
  future==0.18.2 \
  gast==0.4.0 \
  h5py==3.7.0 \
  keras_applications==1.0.8 \
  keras_preprocessing==1.1.2 \
  mock==3.0.5 \
  protobuf \
  pybind11

# Install TensorFlow from Nvidia wheel
TENSORFLOW_INSTALL=https://developer.download.nvidia.com/compute/redist/jp/v61/tensorflow/tensorflow-2.16.1+nv24.08-cp310-cp310-linux_aarch64.whl
pip install --no-cache $TENSORFLOW_INSTALL

# Cleanup
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*/apt/lists/*
