#!/usr/bin/env bash
# Checks the machine meets every prerequisite before anything is installed.
source "$(dirname "$0")/../lib/common.sh"
step "Preflight checks"

[[ "$EUID" -ne 0 ]] || die "Don't run with sudo. Run as your normal user; you'll be asked for your password when needed."

[[ "$(uname -s)" == "Darwin" ]] || die "This setup is for macOS only."

[[ "$(uname -m)" == "arm64" ]] || die "Apple Silicon (M1 or newer) required. Intel Macs aren't supported."
if [[ "$(sysctl -in sysctl.proc_translated 2>/dev/null)" == "1" ]]; then
  die "Your terminal is running under Rosetta. Uncheck 'Open using Rosetta' on the terminal app and retry."
fi
ok "Apple Silicon ($(sysctl -n machdep.cpu.brand_string))"

macos_major="$(sw_vers -productVersion | cut -d. -f1)"
(( macos_major >= 14 )) || die "macOS 14 (Sonoma) or newer required; you have $(sw_vers -productVersion). Update via System Settings → General → Software Update."
ok "macOS $(sw_vers -productVersion)"

id -Gn | grep -qw admin || die "Your account must be an administrator (System Settings → Users & Groups)."
ok "Admin account"

free_gb=$(df -g / | awk 'NR==2 {print $4}')
(( free_gb >= 40 )) || die "At least 40 GB free disk needed (you have ${free_gb} GB). Podman VM + tools + a local model add up."
ok "${free_gb} GB free disk"

mem_gb=$(( $(sysctl -n hw.memsize) / 1073741824 ))
if (( mem_gb >= 16 )); then ok "${mem_gb} GB RAM"; else warn "${mem_gb} GB RAM: works, but 16 GB+ recommended for Podman + local models."; fi

curl -fsS --max-time 10 -o /dev/null https://github.com || die "Can't reach github.com. Check your internet / VPN / proxy."
curl -fsS --max-time 10 -o /dev/null https://formulae.brew.sh || die "Can't reach formulae.brew.sh (Homebrew). Check your network or proxy."
ok "Internet access"

if ! xcode-select -p >/dev/null 2>&1; then
  warn "Installing Xcode Command Line Tools. Click 'Install' in the dialog that appears."
  xcode-select --install || true
  until xcode-select -p >/dev/null 2>&1; do sleep 10; done
fi
ok "Xcode Command Line Tools"

fdesetup status | grep -q "On" && ok "FileVault disk encryption on" \
  || warn "FileVault is OFF. Turn it on: System Settings → Privacy & Security → FileVault."
