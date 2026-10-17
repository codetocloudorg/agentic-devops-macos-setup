#!/usr/bin/env bash
# One-line installer:
#   curl -fsSL https://raw.githubusercontent.com/codetocloudorg/agentic-devops-macos-setup/main/install.sh | bash
# Clones (or updates) the repo into ~/Dev/agentic-devops-macos-setup, then runs bootstrap.sh.
set -euo pipefail

REPO="https://github.com/codetocloudorg/agentic-devops-macos-setup.git"
DEST="${DEST:-$HOME/Dev/agentic-devops-macos-setup}"

[[ "$(uname -m)" == "arm64" ]] || { echo "Apple Silicon Mac required."; exit 1; }

# git ships with the Xcode Command Line Tools
if ! xcode-select -p >/dev/null 2>&1; then
  echo "Installing Xcode Command Line Tools. Click 'Install' in the dialog that appears..."
  xcode-select --install || true
  until xcode-select -p >/dev/null 2>&1; do sleep 10; done
fi

if [[ -d "$DEST/.git" ]]; then
  git -C "$DEST" pull --ff-only
else
  mkdir -p "$(dirname "$DEST")"
  git clone "$REPO" "$DEST"
fi

# Reattach stdin to the terminal so prompts work when piped from curl
cd "$DEST" && exec ./bootstrap.sh "$@" </dev/tty
