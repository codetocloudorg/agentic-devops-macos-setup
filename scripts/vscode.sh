#!/usr/bin/env bash
# Puts `code` on PATH, links settings, installs extensions.
source "$(dirname "$0")/../lib/common.sh"
step "VS Code"

app="/Applications/Visual Studio Code.app"
[[ -d "$app" ]] || die "VS Code not found. Run: ./bootstrap.sh --only packages"

mkdir -p "$HOME/.local/bin"
ln -sf "$app/Contents/Resources/app/bin/code" "$HOME/.local/bin/code"
ok "'code' command available"

link "$CONFIG/vscode/settings.json" "$HOME/Library/Application Support/Code/User/settings.json"

installed="$(code --list-extensions)"
grep -vE '^\s*(#|$)' "$CONFIG/vscode/extensions.txt" | while read -r ext; do
  if grep -qix "$ext" <<<"$installed"; then
    ok "$ext"
  else
    code --install-extension "$ext" >/dev/null && ok "$ext (installed)" || warn "$ext failed; install it from the Extensions view"
  fi
done
