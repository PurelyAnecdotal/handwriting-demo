#!/bin/bash
curl -LsSf https://astral.sh/uv/install.sh | sh
PATH=$PATH:$HOME/.cargo/bin uv venv
PATH=$PATH:$HOME/.cargo/bin uv pip install .