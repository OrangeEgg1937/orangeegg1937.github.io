#!/bin/bash

# Check the update
git submodule update --init

# Install exiftool
sudo apt-get update && sudo apt-get install -y exiftool

if [ -f ".devcontainer/strip_metadata.sh" ]; then
    chmod +x .devcontainer/strip_metadata.sh
else
    echo "Error: .devcontainer/strip_metadata.sh not found."
    exit 1
fi

# Set up Git pre-commit hook
if [ -f ".devcontainer/pre-commit" ]; then
    cp .devcontainer/pre-commit .git/hooks/pre-commit
    chmod +x .git/hooks/pre-commit
else
    echo "Error: .devcontainer/pre-commit not found."
    exit 1
fi

echo "Codespace setup complete: exiftool installed, scripts configured."