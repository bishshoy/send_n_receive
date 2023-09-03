#!/bin/bash

# Example
# ./assemble.sh /path/to/container

files=$(ls $1/bucket.tar.part-* 2> /dev/null)

if [[ -z "$files" ]]; then
    echo "Container is empty"
    exit 1
else
    num_files=$(echo "$files" | wc -l)
    echo "Found $num_files payload files."
fi

echo "Assembling container"

parent_dir=$(dirname "$1")
cat $1/bucket.tar.part-* | tar xf - -C "$parent_dir"

if [ $? -ne 0 ]; then
    echo "Failed to assemble container. Exiting."
    exit 1
fi

echo "Container assembled. You can delete the container now."
