#!/bin/bash

# Example
# ./check.sh /path/to/directory

temp_file=$(mktemp)

num_files=$(find "$1" -type f | wc -l)
echo "Found $num_files files."

OS=$(uname)

if [ "$OS" != "Linux" ] && [ "$OS" != "Darwin" ]; then
  echo "Unsupported OS: $OS"
  exit 1
fi

calculate_checksums() {
  for file in "$1"/*; do
    if [ -d "$file" ]; then
      calculate_checksums "$file"
    elif [ -f "$file" ]; then
      if [ "$OS" = "Linux" ]; then
        checksum=$(md5sum "$file" | awk '{ print $1 }')
      elif [ "$OS" = "Darwin" ]; then
        checksum=$(md5 -q "$file")
      fi
      echo "Checksum of $file: $checksum"
      echo "$checksum" >> "$temp_file"
    fi
  done
}

calculate_checksums $1

sorted_temp_file=$(mktemp)
sort "$temp_file" > "$sorted_temp_file"

if [ "$OS" = "Linux" ]; then
  final_checksum=$(eval "md5sum "$sorted_temp_file" | awk '{ print $1 }'")
elif [ "$OS" = "Darwin" ]; then
  final_checksum=$(eval "md5 -q "$sorted_temp_file"")
fi

echo "The MD5 checksum of the directory is: $final_checksum"

rm -f "$temp_file"
rm -f "$sorted_temp_file"
