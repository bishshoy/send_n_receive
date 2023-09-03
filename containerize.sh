#!/bin/bash

# Example:
# ./containerize.sh /path/to/dir container_name

echo "Creating container"

CONTAINER_NAME="$2.container"

if [ -d "${CONTAINER_NAME}" ]; then
    echo "${CONTAINER_NAME} already exists. Exiting."
    exit 1
else
    mkdir -p "${CONTAINER_NAME}"
fi

echo "Pouring into buckets of size 2G in ${CONTAINER_NAME}"

OS=$(uname)

if [ "$OS" = "Linux" ]; then
  TAR_CMD="tar"
  TAR_OPTS="--transform=\"s|^./||\""
elif [ "$OS" = "Darwin" ]; then
  TAR_CMD="gtar"
  TAR_OPTS="--transform=\"s|^./||\""
else
  echo "Unsupported OS: $OS"
  exit 1
fi

eval "$TAR_CMD cf - -C \"$(dirname "$1")\" $TAR_OPTS \"$(basename "$1")\" | split -b 2G - \"${CONTAINER_NAME}/bucket.tar.part-\""

num_files=$(find "${CONTAINER_NAME}" -maxdepth 1 -type f | wc -l)

echo "Container with ${num_files} buckets created successfully."
