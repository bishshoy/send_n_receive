#!/bin/bash

# Example
# ./check.sh /path/to/directory

temp_file=$(mktemp)

num_files=$(find "$1" -type f | wc -l)
echo "Found $num_files files."

calculate_checksums() {
  for file in "$1"/*; do
    if [ -d "$file" ]; then
      calculate_checksums "$file"
    elif [ -f "$file" ]; then
      checksum=$(md5sum "$file" | awk '{ print $1 }')
      echo "Checksum of $file: $checksum"
      echo "$checksum" >> "$temp_file"
    fi
  done
}

calculate_checksums $1

sorted_temp_file=$(mktemp)
sort "$temp_file" > "$sorted_temp_file"

final_checksum=$(md5sum "$sorted_temp_file" | awk '{ print $1 }')

echo "The MD5 checksum of the directory is: $final_checksum"

rm -f "$temp_file"
rm -f "$sorted_temp_file"
