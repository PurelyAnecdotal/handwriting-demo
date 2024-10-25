#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

if ! command -v uv &> /dev/null; then
    pipx install uv
fi

uv venv
source .venv/bin/activate
uv pip install .