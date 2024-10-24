#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# URL to the Graphviz .deb package
GRAPHVIZ_URL="https://gitlab.com/api/v4/projects/4207231/packages/generic/graphviz-releases/12.1.2/ubuntu_20.04_graphviz-12.1.2-cmake.deb"

# Temporary directory for downloading the package
TEMP_DIR=$(mktemp -d)

# Function to clean up temporary directory
cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

# Check if Graphviz is already installed
if dpkg -l | grep -q graphviz; then
    echo "Graphviz is already installed. Skipping installation."
    exit 0
fi

# Download the Graphviz package
echo "Downloading Graphviz package..."
curl -L -o "$TEMP_DIR/graphviz.deb" "$GRAPHVIZ_URL"

# Install the package
echo "Installing Graphviz..."
sudo dpkg -i "$TEMP_DIR/graphviz.deb"

# Fix any missing dependencies
echo "Fixing missing dependencies..."
sudo apt-get install -f -y

# Delete the .deb file
echo "Deleting the .deb file..."
rm "$TEMP_DIR/graphviz.deb"

echo "Graphviz installation completed successfully."