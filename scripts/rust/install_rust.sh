#!/bin/sh

# Rust toolchain installation script.
#
# Roberto Masocco <r.masocco@dotxautomation.com>
#
# February 11, 2025

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

# This script assumes that the following environment variables have been
# configured according to the desired system-wide installation location.
# - RUSTUP_HOME
# - CARGO_HOME

# Get the desired Rust version
RUST_DEFAULT_VERSION="${1-}"

# Install Rust toolchain
curl https://sh.rustup.rs -sSf | sh -s -- -y --no-modify-path

# Install and set default version
$RUSTUP_HOME/bin/rustup install $RUST_DEFAULT_VERSION
$RUSTUP_HOME/bin/rustup default $RUST_DEFAULT_VERSION

# Symlink all executables
for f in $RUSTUP_HOME/bin/*; do
  echo "Symlinking $(basename $f) to /usr/local/bin/$(basename $f) ..."
  ln -s $f /usr/local/bin/$(basename $f)
done
