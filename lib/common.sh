# Shared helpers for bootstrap scripts. Sourced, not executed.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC2034  # used by the step scripts
CONFIG="$REPO_ROOT/config"
BACKUP_DIR="$HOME/.local/share/agentic-devops-setup/backup/$(date +%Y%m%d-%H%M%S)"

if [[ -t 1 || -n "${FORCE_COLOR:-}" ]]; then
  BLUE=$'\e[34m'; GREEN=$'\e[32m'; YELLOW=$'\e[33m'; RED=$'\e[31m'; BOLD=$'\e[1m'; RESET=$'\e[0m'
else
  BLUE=""; GREEN=""; YELLOW=""; RED=""; BOLD=""; RESET=""
fi

step() { printf "\n%s==> %s%s\n" "$BOLD$BLUE" "$*" "$RESET"; }
ok()   { printf "%s  ✓ %s%s\n" "$GREEN" "$*" "$RESET"; }
warn() { printf "%s  ! %s%s\n" "$YELLOW" "$*" "$RESET"; }
die()  { printf "%s  ✗ %s%s\n" "$RED" "$*" "$RESET" >&2; exit 1; }

has() { command -v "$1" >/dev/null 2>&1; }

# Ask a yes/no question; defaults to yes. CI=1 answers yes; any other non-interactive run answers no.
confirm() {
  [[ "${CI:-}" == "1" ]] && return 0
  [[ -t 0 ]] || return 1
  read -r -p "  ? $1 [Y/n] " reply
  [[ -z "$reply" || "$reply" =~ ^[Yy] ]]
}

# Symlink a repo config file into place, backing up anything already there.
link() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    ok "$dest already linked"; return
  fi
  if [[ -e "$dest" || -L "$dest" ]]; then
    local rel="${dest#"$HOME"/}"
    mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
    mv "$dest" "$BACKUP_DIR/$rel"
    warn "backed up existing ~/$rel to $BACKUP_DIR"
  fi
  ln -s "$src" "$dest"
  ok "linked $dest"
}

load_brew() {
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
}
load_brew
export PATH="$HOME/.local/bin:$PATH"
