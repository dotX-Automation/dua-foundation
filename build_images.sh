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
  echo >&2 "    build_images.sh [OPTIONS] -a | --all | IMAGE [IMAGE ...]"
  echo >&2 "OPTIONS refer to docker-compose build options."
  echo >&2 "-a | --all triggers a build of all images."
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
    -a|--all)
      TARGETS+=("x86-base")
      TARGETS+=("x86-dev")
      TARGETS+=("x86-cudev")
      TARGETS+=("armv8-base")
      TARGETS+=("armv8-dev")
      TARGETS+=("jetson5c7")
      TARGETS+=("jetson4c5")
      ALL_FOUND=1
      echo "Building all images..."
      ;;
    x86-base|x86-dev|x86-cudev|armv8-base|armv8-dev|jetson5c7|jetson4c5)
      if [[ "${ALL_FOUND-0}" != "1" ]]; then
        TARGETS+=("$ARG")
      fi
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
if [[ ${#BUILD_FLAGS[@]} -gt 0 ]]; then
  echo "Build options:" "${BUILD_FLAGS[@]}"
else
  echo "No build options specified"
fi
echo "Images to be built:" "${TARGETS[@]}"

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
