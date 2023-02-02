#!/bin/bash

# Automated DUA base units images build script.
#
# Roberto Masocco <robmasocco@gmail.com>
# Intelligent Systems Lab <isl.torvergata@gmail.com>
#
# February 1, 2023

# NOTE: This requires a valid Docker Hub login.

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then set -o xtrace; fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
  echo >&2 "Usage:"
  echo >&2 "    build_images.sh IMAGE [IMAGE ...] [OPTIONS]"
  echo >&2 "OPTIONS refer to docker-compose build options."
  exit 1
fi

# Check input arguments
TARGETS=()
BUILD_FLAGS=()
if [[ $# -eq 0 ]]; then
  echo >&2 "ERROR: No image specified"
  return 1
fi
for ARG in "$@"
do
  case $ARG in
    x86-base)
      TARGETS+=("$ARG")
      ;;
    x86-dev)
      TARGETS+=("$ARG")
      ;;
    x86-cudev)
      TARGETS+=("$ARG")
      ;;
    --*)
      BUILD_FLAGS+=("$ARG")
      ;;
    *)
      echo >&2 "ERROR: Invalid argument $ARG"
      return 1
      ;;
  esac
done
echo "Build options: " "${BUILD_FLAGS[@]}"

# Log in as ISL
docker login -u intelligentsystemslabutv

# Build requested images
for TARGET in "${TARGETS[@]}"; do
  echo "Building $TARGET image..."
  sleep 3
  if ! docker-compose build "${BUILD_FLAGS[@]}" "$TARGET"; then
    echo >&2 "ERROR: Build target $TARGET failed"
    break
  fi
  echo "Pushing $TARGET image..."
  sleep 3
  docker-compose push "$TARGET"
done
