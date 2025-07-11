#!/bin/sh

# nlohmann/json C++ library installation script.
#
# Roberto Masocco <r.masocco@dotxautomation.com>
#
# July 11, 2025

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

# Get requested library version
JSON_VERSION="${1-}"

# Clone and build library
git clone --single-branch --depth 1 \
  --branch "$JSON_VERSION" \
  https://github.com/nlohmann/json.git \
  /opt/json
cd /opt/json
mkdir build
cd build
cmake \
  -DJSON_BuildTests=OFF \
  ..

# Install library
make
make install

# Cleanup
cd ..
rm -rf build
