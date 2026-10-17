#!/usr/bin/env bash
# Installs every app and CLI tool listed in config/Brewfile.
source "$(dirname "$0")/../lib/common.sh"
step "Apps & CLI tools (config/Brewfile)"

# Some casks need admin rights (e.g. adopting an app you installed by hand).
# Ask for the password once up front and keep sudo alive for this step.
if [[ -t 0 ]]; then
  warn "Some apps need your password to install."
  sudo -v
  while true; do sudo -n true; sleep 50; kill -0 "$$" || exit; done 2>/dev/null &
fi

# Newer Homebrew requires third-party taps to be trusted explicitly. These are official vendor taps.
for tap in hashicorp/tap azure/bicep azure/kubelogin microsoft/foundrylocal; do
  brew tap "$tap" >/dev/null
  if brew help trust >/dev/null 2>&1; then brew trust "$tap" >/dev/null; fi
done

# Some casks (fonts, Podman Desktop) can ask for your password.
brew bundle --file "$CONFIG/Brewfile"
ok "All Brewfile packages installed"
