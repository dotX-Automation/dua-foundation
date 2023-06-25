#!/bin/bash

# Automated DUA utils Dockerfiles update script.
#
# Roberto Masocco <robmasocco@gmail.com>
# Intelligent Systems Lab <isl.torvergata@gmail.com>
#
# June 25, 2023

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then set -o xtrace; fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
  echo >&2 "Usage:"
  echo >&2 "    utils_update.sh VERSION"
  echo >&2 "VERSION must be the new version tag."
  exit 1
fi

# Check input arguments
if [[ $# -ne 1 ]]; then
  echo >&2 "ERROR: No version tag specified"
  exit 1
fi

# Update dua-utils version tag in Dockerfiles
for FILE in Dockerfile*; do
  sed -i "s/ARG DUA_UTILS_VERSION=.*/ARG DUA_UTILS_VERSION=$1/g" "$FILE"
done
