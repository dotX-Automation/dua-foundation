#!/bin/bash

# Saves Docker images to compressed archives.
#
# Roberto Masocco <robmasocco@gmail.com>
# Intelligent Systems Lab <isl.torvergata@gmail.com>
#
# February 1, 2023

# NOTE: This requires a lot of disk space.

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then set -o xtrace; fi

function usage {
  echo >&2 "Usage:"
  echo >&2 "    save_images.sh [OPTIONS] TAG..."
  echo >&2 "Options:"
  echo >&2 "-d DIRECTORY    Directory in which to save images"
  echo >&2 "-r REPO         Full image repository name"
  echo >&2 "-l              Do not pull images, using locally available ones instead"
}

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
  usage
  exit 1
fi

REPO=intelligentsystemslabutv/dua-foundation
SAVEDIR=/home/$USER/Downloads
LOCAL=""

# Parse options
while getopts ":d:r:l" OPT; do
  case "${OPT}" in
    d)
      SAVEDIR="${OPTARG}"
      ;;
    r)
      REPO="${OPTARG}"
      ;;
    l)
      LOCAL="y"
      ;;
    *)
      usage
      exit 1
      ;;
  esac
done
shift $((OPTIND - 1))

# Check input arguments
TAGS=()
if [[ $# -eq 0 ]]; then
  echo >&2 "ERROR: No image tag specified"
  usage
  exit 1
fi
for ARG in "$@"
do
  TAGS+=("$ARG")
done

# Pull images if required
if [[ -z "$LOCAL" ]]; then
  echo "Pulling all images..."
  sleep 3
  for TAG in "${TAGS[@]}"; do
    docker pull "$REPO:$TAG" || exit 1
  done
fi

echo "Images will be saved to $SAVEDIR directory, compressed with pigz"
sleep 1

for TAG in "${TAGS[@]}"; do
  echo "Saving $TAG image..."
  docker save "$REPO:$TAG" | pigz -c > "$SAVEDIR/${REPO##*/}-$TAG.gz" || exit 1
done
