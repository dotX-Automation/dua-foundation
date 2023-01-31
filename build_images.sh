#!/bin/bash

# Automated Stanis project images builder script.
#
# Roberto Masocco <robmasocco@gmail.com>
#
# April 4, 2022

# NOTE: For JORDAN or other heavy-duty systems only!
# NOTE: Make sure that a Docker Hub PAT is enabled for this system!
# NOTE: Make sure that the system is capable of building multi-arch images!

# Verify that the PWD is the project root directory
CURR_DIR=${PWD##*/}
REQ_CURR_DIR="stanis"
if [[ $CURR_DIR != "$REQ_CURR_DIR" ]]; then
  echo >&2 "ERROR: Wrong path, this script must run inside $REQ_CURR_DIR"
  return 1
fi

# Check input arguments
TARGETS=()
BUILD_FLAGS=("--pull")
if [[ $# -eq 0 ]]; then
  echo >&2 "ERROR: No image specified"
  return 1
fi
for ARG in "$@"
do
  case $ARG in
    base-nx)
      TARGETS+=("$ARG")
      ;;
    base)
      TARGETS+=("$ARG")
      ;;
    dev)
      TARGETS+=("$ARG")
      ;;
    nvidia)
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

cd docker || return 1

# Log in as ISL
unalias docker
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

cd ../
