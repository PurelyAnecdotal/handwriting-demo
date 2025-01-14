#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function to install bun
install_bun() {
    echo "Installing bun..."
    curl -fsSL https://bun.sh/install | bash
    export PATH="$HOME/.bun/bin:$PATH"
    echo "Bun installed successfully."
}

# Ensure the PATH includes the bun bin directory
export PATH="$HOME/.bun/bin:$PATH"

# Check if bun is installed, if not, install it
if ! command -v bun &> /dev/null; then
    install_bun
else
    echo "Bun is already installed."
fi

cd ./webui

bun install

bun run build
bun --bun run preview --host