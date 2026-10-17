#!/usr/bin/env bash
# AI coding agents (Claude Code, GitHub Copilot CLI, OpenCode) and Foundry Local for on-device models.
source "$(dirname "$0")/../lib/common.sh"
step "AI agents"

if ! has claude; then
  curl -fsSL https://claude.ai/install.sh | bash
fi
ok "Claude Code $(claude --version 2>/dev/null | head -1)"

if has copilot; then ok "GitHub Copilot CLI $(copilot --version 2>/dev/null | head -1)"; else warn "Copilot CLI missing; run ./bootstrap.sh --only packages"; fi

if has opencode; then ok "OpenCode $(opencode --version 2>/dev/null | head -1)"; else warn "OpenCode missing; run ./bootstrap.sh --only packages"; fi
if has foundry; then ok "Foundry Local $(foundry --version 2>/dev/null)"; else warn "Foundry Local missing; run ./bootstrap.sh --only packages"; fi
echo "    Try a local model (several GB download, runs on the Apple GPU):"
echo "      foundry model list"
echo "      foundry model run phi-4-mini"
echo "    Sign in to your agents: run 'claude', 'copilot' and 'opencode' once each."
