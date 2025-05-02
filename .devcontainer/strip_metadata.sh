#!/bin/bash

# Get list of staged .png and .jpg files
staged_files=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(png|jpg)$')

# Check if there are any .png or .jpg files
if [ -z "$staged_files" ]; then
    echo "No .png or .jpg files staged for commit."
    exit 0
fi

# Remove metadata from each staged file
while IFS= read -r file; do
    if [ -f "$file" ]; then
        echo "Removing metadata from: $file"
        exiftool -all= "$file"
        # Remove the original backup file created by exiftool
        rm -f "${file}_original"
        # Re-stage the modified file
        git add "$file"
    fi
done <<< "$staged_files"

echo "Metadata removal complete."
exit 0