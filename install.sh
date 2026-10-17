#!/usr/bin/env bash
# One-line installer:
#   curl -fsSL https://raw.githubusercontent.com/codetocloudorg/agentic-devops-macos-setup/main/install.sh | bash
# Clones the repo into ~/Dev/agentic-devops-macos-setup at the LATEST RELEASE TAG (not main),
# so only reviewed, released code runs. Override with REF=main or REF=v1.2.0.
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

REF="${REF:-$(git ls-remote --tags --refs --sort=-version:refname "$REPO" 'v*' | head -1 | sed 's|.*refs/tags/||')}"
REF="${REF:-main}"
echo "Installing $REF"

if [[ -d "$DEST/.git" ]]; then
  git -C "$DEST" fetch --tags --quiet origin
  git -C "$DEST" checkout --quiet "$REF"
  [[ "$REF" == "main" ]] && git -C "$DEST" pull --ff-only --quiet
else
  mkdir -p "$(dirname "$DEST")"
  git clone --quiet --branch "$REF" "$REPO" "$DEST"
fi

# Reattach stdin to the terminal so prompts work when piped from curl
cd "$DEST" && exec ./bootstrap.sh "$@" </dev/tty
