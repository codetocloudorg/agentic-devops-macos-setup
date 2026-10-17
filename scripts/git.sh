#!/usr/bin/env bash
# Sets your Git identity and recommended global defaults.
# Non-interactive: GIT_NAME="Jane Doe" GIT_EMAIL="jane@example.com" ./bootstrap.sh --only git
source "$(dirname "$0")/../lib/common.sh"
step "Git"

g() { git config --global "$@"; }

name="$(git config --global user.name || true)"
email="$(git config --global user.email || true)"
[[ -n "$name"  ]] || name="${GIT_NAME:-}"
[[ -n "$email" ]] || email="${GIT_EMAIL:-}"
[[ -n "$name"  ]] || read -r -p "  ? Your full name for Git commits: " name
[[ -n "$email" ]] || read -r -p "  ? Your email for Git commits: " email
[[ -n "$name" && -n "$email" ]] || die "Git name and email are required."
g user.name "$name"
g user.email "$email"

g init.defaultBranch main
g pull.rebase true
g rebase.autoStash true
g rebase.updateRefs true
g push.autoSetupRemote true
g push.default current
g fetch.prune true
g rerere.enabled true
g diff.algorithm histogram
g diff.colorMoved default
g merge.conflictStyle zdiff3
g branch.sort -committerdate
g tag.sort version:refname
g column.ui auto
g help.autocorrect prompt
g core.excludesFile "$HOME/.config/git/ignore"
g core.pager delta
g interactive.diffFilter "delta --color-only"
g delta.navigate true
g delta.line-numbers true
g credential.helper osxkeychain
ok "Git configured for $name <$email>"
