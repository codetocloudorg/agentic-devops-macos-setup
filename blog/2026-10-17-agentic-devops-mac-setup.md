---
title: "Setting up a Mac for Agentic DevOps"
date: 2026-10-17
author: Kevin Evans
tags: [macos, apple-silicon, devops, ai-agents, azure, podman, ghostty]
---

# Setting up a Mac for Agentic DevOps

*How I set up a new Apple Silicon MacBook for cloud engineering in the age of AI coding agents, and turned it into a one-command bootstrap anyone can repeat.*

---

## Why "agentic" DevOps?

A few years ago a DevOps workstation was a terminal, an editor, Docker and a cloud CLI. That's still the foundation, but the way we work has changed: **a good chunk of the typing is now done by AI agents.** Claude Code, GitHub Copilot and OpenCode write the Bicep, run `terraform plan`, read the failing pipeline logs and open the pull request.

That changes what a "good" dev machine is:

1. **Agents use the same tools you do.** If `az`, `kubectl`, `podman` and `gh` aren't installed and signed in, the agent can't use them either. A complete, consistent toolchain makes agents dramatically more useful.
2. **Agents need guardrails.** When something else writes code at speed, you want automatic checks: secret scanning, IaC scanning, linting and signed commits. Those belong on the laptop, not just in CI.
3. **Not everything should leave your machine.** Apple Silicon is good at running models locally, so a local model runtime is now part of the kit for private or offline work.
4. **It must be reproducible.** A setup you did by hand once is one you can't explain, share or rebuild. Everything here is code.

So the goal: **a fresh Mac to a fully working, agent-ready DevOps machine with one command, where every choice is explained.**

### Minimal by default

Developers (rightly) hate bloated setups. Every tool here has to earn its place in **core**. Everything else, such as GUIs, prettier `ls`, themes and extra VS Code extensions, lives in an **extras** list that the bootstrap offers with a default of *no*. You get a lean machine and opt in to the rest.

---

## Step 0: Prerequisites

Before touching anything, check the basics. The bootstrap's `preflight` step does this for you and refuses to continue if something's wrong:

- **Apple Silicon** (M1 or newer). Everything here is arm64-native, and some tools (Foundry Local, for one) rely on the Apple GPU.
- **macOS 14+**, an **admin account**, **40 GB free**, ideally **16 GB+ RAM**.
- A terminal that **isn't running under Rosetta**. This one catches people out and silently installs Intel binaries.
- **FileVault on.** This is a machine full of cloud credentials.

## Step 1: Homebrew and a Brewfile

Everything starts with [Homebrew](https://brew.sh). The important habit is to **never `brew install` ad hoc**. Every package goes in a [`Brewfile`](../config/Brewfile), and `brew bundle` installs the lot. The Brewfile becomes the inventory of your machine and the thing you share with your team.

One gotcha in recent Homebrew: third-party taps (HashiCorp, Azure and Microsoft all ship their own) must be explicitly **trusted** before their formulas will install. That's a good security change; the bootstrap trusts only those official vendor taps.

## Step 2: A terminal worth living in

I switched to **[Ghostty](https://ghostty.org)**. It's fast, native and GPU-rendered, and its config is a plain text file that lives in git. Paired with:

- **JetBrains Mono Nerd Font** for ligatures and icons
- **Starship** for a prompt that shows git branch, runtime versions and cloud context
- **zoxide** (`z api` jumps to `~/Dev/big-project/src/api`) and **fzf** (**Ctrl‑R** fuzzy history)
- **tmux** with a `Ctrl‑a` prefix, mouse support and splits that open in the current folder, for long-running sessions you can detach from

Ghostty and VS Code both use the **Catppuccin** theme and switch between light and dark with macOS.

## Step 3: Containers, with Podman

I use **[Podman](https://podman.io)** instead of Docker Desktop. It's open source, rootless by default, needs no licence for business use, and is Docker-compatible:

- `alias docker=podman` and `podman-compose` cover day-to-day use
- `DOCKER_HOST` points at Podman's socket so tools like Testcontainers and VS Code Dev Containers work
- the VM is sized to half your CPU cores and up to 8 GB RAM

## Step 4: Git done properly

Out of the box Git's defaults are dated. The [`git` step](../scripts/git.sh) sets the defaults most experienced engineers end up with: `main` as default branch, rebase on pull with auto-stash, auto-upstream on first push, prune on fetch, `rerere`, `zdiff3` conflicts, the histogram diff algorithm and `delta` as the pager.

The [`github` step](../scripts/github.sh) signs in the **GitHub CLI** and lets git use it for HTTPS credentials. It also offers to create an **SSH key used for both authentication and commit signing**. When agents are writing code on your behalf, a *Verified* badge on your commits matters more than ever.

## Step 5: Azure and Infrastructure as Code

For Azure work the kit is `az`, **`azd`** (one command to provision and deploy a whole app) and **Bicep**. For multi-cloud, **Terraform** *and* **OpenTofu**: OpenTofu is the community open-source fork created after Terraform's licence change, and many teams now use it by default. **TFLint** catches mistakes early. Kubernetes comes with **kubectl**, **Helm** and **kubelogin**, which handles Entra ID sign-in for AKS.

## Step 6: The agents

Three agents, because they're good at different things and teams use different ones:

- **[Claude Code](https://claude.com/claude-code)**: an agentic coding tool in the terminal and VS Code. Installed with Anthropic's native installer so it keeps itself updated.
- **[GitHub Copilot CLI](https://docs.github.com/copilot)**: GitHub's coding agent, deeply tied into issues, PRs and Actions.
- **[OpenCode](https://opencode.ai)**: open source and model-agnostic. Point it at any provider, including a local model.

### Should you install Foundry Local? Yes.

**[Foundry Local](https://aka.ms/foundry-local)** runs open models (Phi, Qwen, Mistral and others) on-device, using the Apple Silicon GPU, behind an OpenAI-compatible API. It's worth having because:

- **Privacy:** sensitive code and logs never leave the laptop
- **Offline:** works on a plane
- **Cost:** free experimentation for agent prototypes before pointing them at Azure AI Foundry in the cloud
- **Same API shape:** code you write against the local endpoint moves to the cloud with minimal change

```bash
foundry model list
foundry model run phi-4-mini
```

Models are several GB each, so the bootstrap installs the runtime but leaves model downloads to you.

## Step 7: Guardrails

These run on the laptop so problems are caught before a push:

- **gitleaks:** secrets in commits
- **Trivy:** misconfigured Bicep/Terraform, vulnerable images and dependencies
- **pre-commit:** runs the above automatically
- *(extras)* **act** to run GitHub Actions locally, and **ShellCheck** for shell scripts

## Step 8: VS Code

It's easy to end up with 40 VS Code extensions, each one slowing startup and adding noise. Core is **8**:

| Extension | Why it's core |
|---|---|
| Claude Code, GitHub Copilot | The agents, inside the editor |
| Bicep, Terraform | IaC language support and formatting |
| Dev Containers | Reproducible project environments (wired to Podman) |
| GitHub Actions | Pipelines are code too |
| YAML | Pipelines, Kubernetes and compose files |
| EditorConfig | Respect each repo's formatting rules |

Everything else comes as **optional packs** you pick: Theme, Git (GitLens), Containers & Kubernetes, Azure & scripting, Python, Web, Writing & quality. Settings format on save, turn telemetry off and keep the UI quiet.

## Step 9: Give every repo rules for its agents

Agents are only as safe as the instructions they get. The repo includes a generic **[`AGENTS.md`](../templates/AGENTS.md)**, the emerging cross-tool standard read by Copilot, OpenCode and others, with DevOps safety rules baked in:

- `plan` and `what-if` are fine; **`apply`, `deploy` and `destroy` are for humans**
- never delete cloud resources unasked; check the subscription and cluster context first
- never read or commit secrets; prefer managed identity and Key Vault
- branches and small commits, never force-push

**[`CLAUDE.md`](../templates/CLAUDE.md)** simply imports `AGENTS.md`, so there's one set of rules for every agent. A **[`.claude/settings.json`](../templates/.claude/settings.json)** goes further and *enforces* it: Claude Code must ask before `terraform apply`, `azd up` or `kubectl delete`, and its file-reading tool is blocked from `.env`, keys, `*.tfvars` and state files. Treat that as a guardrail, not a sandbox: the real fix is keeping secrets out of the repo entirely.

Type `agent-init` in any repo to drop all three in.

## Step 10: macOS for developers

A short list of settings that make macOS friendlier to engineers: a Dock with only your dev apps that hides itself, Finder showing extensions, hidden files and the path, fast key repeat, and, importantly, **smart quotes and dashes turned off**, because a curly quote in a pasted command is a classic time-waster. The firewall gets turned on too. The script backs up your current settings first.

---

## Making it bulletproof

A setup script is only useful if a developer can run it on an unfamiliar machine without you in the room. So the bootstrap:

- **checks prerequisites first** and fails with a plain-English fix
- is **idempotent**: re-run it as often as you like
- **backs up** anything it would overwrite
- **logs** every run and, on failure, prints the exact command to resume
- **symlinks** config to the repo, so `git pull` updates your machine
- is **linted and secret-scanned in CI** on every push
- can be **driven by Claude Code** itself: open the repo, type `/bootstrap`

## What's still missing (on purpose)

Things I left out but you may want:

- **Secrets management:** a password manager CLI (Bitwarden or 1Password) so agents and scripts never see raw secrets in `.env` files
- **A local Kubernetes cluster:** `kind` or `minikube` on Podman for testing Helm charts
- **MCP servers:** connect your agents to Azure, GitHub and docs through the Model Context Protocol
- **Window management and launcher:** Rectangle and Raycast
- **Backups:** Time Machine. Your dotfiles are in git, but your work-in-progress isn't
- **Hardware-backed keys:** `ssh-keygen -t ed25519-sk` with a YubiKey for phishing-resistant SSH

## Try it

```bash
curl -fsSL https://raw.githubusercontent.com/codetocloudorg/agentic-devops-macos-setup/main/install.sh | bash
```

Or read every script first (recommended): [github.com/codetocloudorg/agentic-devops-macos-setup](https://github.com/codetocloudorg/agentic-devops-macos-setup).

*Provided as-is with no warranty. Read the [disclaimer](../README.md#disclaimer) before running on a machine you care about.*
