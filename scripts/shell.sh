#!/usr/bin/env bash
# Links shell, terminal and tmux config into your home folder.
source "$(dirname "$0")/../lib/common.sh"
step "Shell, Ghostty & tmux config"

link "$CONFIG/zsh/zshrc"          "$HOME/.zshrc"
link "$CONFIG/tmux/tmux.conf"     "$HOME/.tmux.conf"
link "$CONFIG/ghostty/config"     "$HOME/.config/ghostty/config"
link "$CONFIG/git/ignore"         "$HOME/.config/git/ignore"
touch "$HOME/.zshrc.local"   # your personal, untracked additions

[[ "$SHELL" == "/bin/zsh" ]] || { warn "Switching default shell to zsh"; chsh -s /bin/zsh; }

if [[ -x /Applications/Ghostty.app/Contents/MacOS/ghostty ]]; then
  /Applications/Ghostty.app/Contents/MacOS/ghostty +validate-config >/dev/null && ok "Ghostty config valid"
fi
