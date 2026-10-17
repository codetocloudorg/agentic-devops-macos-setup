#!/usr/bin/env bash
# Health check: shows every tool's status. Safe to run anytime.
source "$(dirname "$0")/../lib/common.sh"
step "Verify"
eval "$(mise activate bash --shims 2>/dev/null)" || true

fail=0
check() { if has "$1"; then ok "$(printf '%-11s' "$1") $( ("$@" 2>/dev/null || true) | head -1)"; else warn "$1 missing"; fail=1; fi; }

check git --version
check gh --version
check code --version
check tmux -V
check starship --version
check podman --version
check kubectl version --client
check helm version --short
check az version --query '"azure-cli"' -o tsv
check azd version
check bicep --version
check terraform version
check tofu version
check tflint --version
check trivy --version
check gitleaks version
check node --version
check python --version
check uv --version
check claude --version
check copilot --version
check opencode --version
check foundry --version

podman machine inspect --format '{{.State}}' 2>/dev/null | grep -q running && ok "Podman VM running" || warn "Podman VM not running: podman machine start"
gh auth status >/dev/null 2>&1 && ok "Signed in to GitHub" || warn "Not signed in to GitHub: gh auth login"
az account show >/dev/null 2>&1 && ok "Signed in to Azure" || warn "Not signed in to Azure: az login && azd auth login"

(( fail == 0 )) && ok "Everything installed" || die "Some tools are missing. Re-run ./bootstrap.sh (it's safe to repeat)."
