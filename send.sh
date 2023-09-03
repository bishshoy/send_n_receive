#!/bin/bash

# Example
# ./send.sh /path/to/container user@host:/path/to/destination

if ! command -v bbcp &> /dev/null; then
    echo "Error: bbcp could not be found in your PATH."
    exit 1
fi

CONTAINER_NAME=$(basename "$1")
DEST_USER_HOST=${2%%:*}
DEST_PATH="${2#*:}/${CONTAINER_NAME}"

echo "Creating container on server"

ssh "${DEST_USER_HOST}" "mkdir -p $DEST_PATH"

if [ $? -ne 0 ]; then
    echo "Failed to create container on server."
    exit 1
fi

for full_path in $1/bucket.tar.part-*; do
    file=$(basename "$full_path")

    echo "Checking payload ${file}"

    REMOTE_SIZE=$(ssh $DEST_USER_HOST "stat -c %s $DEST_PATH/$file" 2>/dev/null)

    if [[ -n "$REMOTE_SIZE" && $(stat -c %s "$full_path") -eq $REMOTE_SIZE ]]; then
        echo "${file} already exists at destination with the same size. Skipping..."
        continue
    fi

    echo "Sending payload ${file}"

    bbcp -V -s 32 -d "$1" "${file}" "${DEST_USER_HOST}:${DEST_PATH}"

    if [ $? -ne 0 ]; then
        echo "Error: bbcp failed for ${file}. Exiting."
        exit 1
    fi
done

echo "Container sent. You can delete the container now."
