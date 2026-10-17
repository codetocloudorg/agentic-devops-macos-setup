# Agentic DevOps macOS Setup

Bootstrap scripts for an Apple Silicon Mac developer workstation. Bash 3.2 compatible (macOS's /bin/bash).

## Layout
- `bootstrap.sh`: runs `scripts/<step>.sh` in order; `--only`, `--skip`, `--list`
- `scripts/`: one idempotent step per file; all source `lib/common.sh` (step/ok/warn/die, confirm, link)
- `config/`: files symlinked into `$HOME` (Brewfile, zshrc, ghostty, tmux, git ignore, mise, vscode)
- `blog/`: long-form write-up; keep it in sync with what the scripts actually do

## Rules
- Every step must be safe to re-run and must back up before overwriting (use `link`).
- Never put personal data (names, emails, keys) in `config/`; prompt for it in scripts.
- Lint before committing: `shellcheck -s bash bootstrap.sh install.sh lib/*.sh scripts/*.sh`
- When adding a tool: Brewfile, README "What gets installed" table, and `scripts/verify.sh`.

## Helping someone set up their Mac
Use the `/bootstrap` skill.
