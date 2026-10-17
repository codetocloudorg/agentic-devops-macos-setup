#!/usr/bin/env bash
# Installs Homebrew and puts it on PATH for login shells.
source "$(dirname "$0")/../lib/common.sh"
step "Homebrew"

if ! has brew; then
  warn "Homebrew needs your password once."
  sudo -v
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  load_brew
fi
has brew || die "Homebrew install failed. See https://brew.sh"

grep -qs 'brew shellenv' "$HOME/.zprofile" || echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
brew update --quiet
ok "$(brew --version | head -1)"
