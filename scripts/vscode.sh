#!/usr/bin/env bash
# Puts `code` on PATH, links settings, installs the core extensions (optional packs on request).
source "$(dirname "$0")/../lib/common.sh"
step "VS Code"

app="/Applications/Visual Studio Code.app"
[[ -d "$app" ]] || die "VS Code not found. Run: ./bootstrap.sh --only packages"

mkdir -p "$HOME/.local/bin"
ln -sf "$app/Contents/Resources/app/bin/code" "$HOME/.local/bin/code"
ok "'code' command available"

link "$CONFIG/vscode/settings.json" "$HOME/Library/Application Support/Code/User/settings.json"

install_list() {
  local installed; installed="$(code --list-extensions)"
  sed -e 's/#.*//' -e 's/[[:space:]]*$//' "$1" | grep -v '^$' | while read -r ext; do
    if grep -qix "$ext" <<<"$installed"; then
      ok "$ext"
    elif code --install-extension "$ext" >/dev/null 2>&1; then
      ok "$ext (installed)"
    else
      warn "$ext failed; install it from the Extensions view"
    fi
  done
}

install_list "$CONFIG/vscode/extensions.txt"

# Optional packs (theme, GitLens, Python, web, …). EXTRAS=1 installs without asking.
if [[ "${EXTRAS:-}" == "1" ]] || confirm_no "Also install optional extension packs (see config/vscode/extensions-extras.txt)?"; then
  install_list "$CONFIG/vscode/extensions-extras.txt"
fi
