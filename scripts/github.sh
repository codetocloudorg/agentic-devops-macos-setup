#!/usr/bin/env bash
# Signs in to GitHub CLI, wires it into git, and (optionally) creates an SSH key for auth + commit signing.
source "$(dirname "$0")/../lib/common.sh"
step "GitHub CLI & SSH"

if gh auth status >/dev/null 2>&1; then
  ok "Already signed in to GitHub as $(gh api user --jq .login)"
else
  warn "A browser window will open to sign in to GitHub."
  gh auth login --hostname github.com --git-protocol https --web </dev/tty >/dev/tty 2>&1
fi
gh auth setup-git
ok "git uses GitHub CLI for HTTPS credentials"

key="$HOME/.ssh/id_ed25519"
if [[ ! -f "$key" ]] && confirm "Create an SSH key for GitHub (auth + signed commits)?"; then
  mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
  warn "Choose a passphrase. It's stored in the macOS Keychain so you only type it once."
  ssh-keygen -t ed25519 -C "$(git config --global user.email)" -f "$key"
  ssh-add --apple-use-keychain "$key"
fi

if [[ -f "$key" ]]; then
  grep -qs "UseKeychain" "$HOME/.ssh/config" || cat >> "$HOME/.ssh/config" <<'CFG'
Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
CFG
  chmod 600 "$HOME/.ssh/config"

  pub="$(cut -d' ' -f1,2 "$key.pub")"
  if ! gh ssh-key list 2>/dev/null | grep -qF "${pub#* }"; then
    gh auth refresh -h github.com -s admin:public_key,admin:ssh_signing_key </dev/tty >/dev/tty 2>&1
    gh ssh-key add "$key.pub" --type authentication --title "$(scutil --get ComputerName)"
    gh ssh-key add "$key.pub" --type signing --title "$(scutil --get ComputerName) signing"
  fi

  git config --global gpg.format ssh
  git config --global user.signingkey "$key.pub"
  git config --global commit.gpgsign true
  git config --global tag.gpgsign true
  ok "SSH key on GitHub; commits are signed (shows 'Verified')"
fi
