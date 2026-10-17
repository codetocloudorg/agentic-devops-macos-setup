#!/usr/bin/env bash
# Developer-friendly macOS settings: Dock, Finder, keyboard, screenshots, firewall.
source "$(dirname "$0")/../lib/common.sh"
step "macOS settings"

confirm "Apply developer macOS settings (Dock, Finder, keyboard)?" || { warn "Skipped"; exit 0; }

mkdir -p "$BACKUP_DIR"
for d in com.apple.dock com.apple.finder NSGlobalDomain com.apple.screencapture; do
  defaults export "$d" "$BACKUP_DIR/$d.plist"
done
ok "Current settings backed up to $BACKUP_DIR (restore: defaults import <domain> <file>)"

# ---- Dock: just your dev apps ----
dockutil --remove all --no-restart >/dev/null
for app in "/Applications/Ghostty.app" "/Applications/Visual Studio Code.app" \
           "/Applications/Podman Desktop.app" "/System/Applications/System Settings.app"; do
  [[ -e "$app" ]] && dockutil --add "$app" --no-restart >/dev/null
done
dockutil --add "$HOME/Downloads" --view grid --display folder --sort dateadded --no-restart >/dev/null
defaults write com.apple.dock tilesize -int 48
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.3
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock minimize-to-application -bool true
defaults write com.apple.dock mru-spaces -bool false

# ---- Finder ----
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
defaults write com.apple.finder FXPreferredViewStyle -string Nlsv
defaults write com.apple.finder FXDefaultSearchScope -string SCcf
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.finder _FXSortFoldersFirst -bool true
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
chflags nohidden "$HOME/Library"

# ---- Keyboard: fast repeat, no "smart" punctuation that breaks code ----
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain AppleKeyboardUIMode -int 2

# ---- Misc ----
mkdir -p "$HOME/Pictures/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Pictures/Screenshots"
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

killall Dock Finder SystemUIServer 2>/dev/null || true
ok "Settings applied (key repeat takes effect after logout)"

fw=/usr/libexec/ApplicationFirewall/socketfilterfw
if ! "$fw" --getglobalstate | grep -q enabled && confirm "Turn on the macOS firewall? (needs password)"; then
  sudo "$fw" --setglobalstate on >/dev/null && ok "Firewall on"
fi
