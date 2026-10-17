#!/usr/bin/env bash
# Installs language runtimes with mise (Node LTS, Python, tflint).
source "$(dirname "$0")/../lib/common.sh"
step "Language runtimes (mise)"

link "$CONFIG/mise/config.toml" "$HOME/.config/mise/config.toml"
mise install --yes
eval "$(mise activate bash --shims)"
ok "node $(node -v), $(python --version), $(tflint --version | head -1)"
