#!/usr/bin/env bash
# Agentic DevOps macOS bootstrap (Apple Silicon).
#
#   ./bootstrap.sh                 run every step
#   ./bootstrap.sh --only vscode   run one step (or several: --only "git github")
#   ./bootstrap.sh --skip macos    run everything except some steps
#   ./bootstrap.sh --list          show the steps
#
# Every step is safe to re-run.
set -euo pipefail
cd "$(dirname "$0")"

LOG_DIR="$HOME/.local/share/agentic-devops-setup"
mkdir -p "$LOG_DIR"
LOG="$LOG_DIR/bootstrap-$(date +%Y%m%d-%H%M%S).log"
[[ -t 1 ]] && export FORCE_COLOR=1
exec > >(tee -a "$LOG") 2>&1
echo "Logging to $LOG"

STEPS=(preflight homebrew packages shell git github runtimes podman vscode macos ai verify)
only=""; skip=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --only) only="$2"; shift 2 ;;
    --skip) skip="$2"; shift 2 ;;
    --list) printf '%s\n' "${STEPS[@]}"; exit 0 ;;
    -h|--help) sed -n '2,10p' "$0"; exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

for s in "${STEPS[@]}"; do
  [[ -n "$only" && " $only " != *" $s "* ]] && continue
  [[ " $skip " == *" $s "* ]] && continue
  if ! bash "scripts/$s.sh"; then
    printf "\n\e[1;31mStep '%s' failed.\e[0m Fix the issue above, then resume with:\n  ./bootstrap.sh --only \"%s\"\nFull log: %s\n" "$s" "$s" "$LOG"
    exit 1
  fi
done

printf "\nAll done. Open Ghostty (or a new terminal) to load your new shell.\nRe-check anytime with: ./bootstrap.sh --only verify\n"
