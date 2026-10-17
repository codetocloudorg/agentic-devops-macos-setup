# Agentic DevOps macOS Setup

**A complete, repeatable developer workstation for Apple Silicon Macs, built for engineers who ship to the cloud *alongside* AI coding agents.**

One command takes a fresh Mac to a fully configured DevOps machine: terminal, editor, containers, Kubernetes, Azure, Infrastructure as Code, security guardrails, and three AI coding agents plus local models.

> 📝 **Want the story behind each choice?** Read the blog post: [Setting up a Mac for Agentic DevOps](blog/2026-10-17-agentic-devops-mac-setup.md)

> ⚠️ **Apple Silicon only** (M1, M2, M3, M4 and newer). Intel Macs are not supported.

---

## Contents

- [Prerequisites](#prerequisites)
- [Quick start](#quick-start)
- [What gets installed](#what-gets-installed)
- [How it works](#how-it-works)
- [Bootstrap with Claude Code](#bootstrap-with-claude-code)
- [Agent instructions for your projects](#agent-instructions-for-your-projects)
- [After installing](#after-installing)
- [Customising](#customising)
- [Troubleshooting](#troubleshooting)
- [Undoing changes](#undoing-changes)
- [Disclaimer](#disclaimer)

---

## Prerequisites

Check these **before** you start. The `preflight` step verifies all of them automatically and stops with a clear fix if anything is missing.

| ✅ | Requirement | How to check |
|---|---|---|
| ☐ | **Apple Silicon Mac** (M1 or newer) |  → About This Mac → *Chip* says "Apple M…" |
| ☐ | **macOS 14 Sonoma or newer** |  → About This Mac |
| ☐ | **Administrator account** | System Settings → Users & Groups → your account says *Admin* |
| ☐ | **40 GB free disk** | System Settings → General → Storage |
| ☐ | **16 GB RAM recommended** (8 GB works, but slower for containers and local models) |  → About This Mac |
| ☐ | **Internet access** to github.com and brew.sh (check VPN or proxy) | Open https://brew.sh in a browser |
| ☐ | **A GitHub account** | https://github.com/signup |
| ☐ | **An Azure subscription** (optional, for the Azure tools) | https://portal.azure.com |
| ☐ | **~45 minutes** and the Mac plugged into power | |
| ☐ | **Terminal *not* running under Rosetta** | Finder → Applications → Utilities → Terminal → Get Info → "Open using Rosetta" is **unchecked** |

You'll be asked for your **Mac password** a few times (Homebrew, some apps, the firewall) and to **sign in to GitHub** in your browser. Stay at the keyboard for the first ~10 minutes.

> FileVault disk encryption should be on. Preflight warns you if it isn't.

---

## Quick start

Open **Terminal** (⌘ Space → "Terminal") and paste:

```bash
curl -fsSL https://raw.githubusercontent.com/codetocloudorg/agentic-devops-macos-setup/main/install.sh | bash
```

This installs the Xcode Command Line Tools (for `git`), clones the **latest release** of this repo to `~/Dev/agentic-devops-macos-setup`, and runs the bootstrap. (`REF=main` gets the bleeding edge.)

**Prefer to read the code first?** (Recommended.)

```bash
xcode-select --install          # skip if already installed
git clone https://github.com/codetocloudorg/agentic-devops-macos-setup.git ~/Dev/agentic-devops-macos-setup
cd ~/Dev/agentic-devops-macos-setup
./bootstrap.sh
```

When it finishes, **quit Terminal and open Ghostty**. Then log out and back in so the keyboard settings apply.

---

## What gets installed

**Minimal by default.** The core install is only what an agent-assisted DevOps workflow needs. Nice-to-haves are optional extras that the bootstrap offers (default **no**), or you can install them yourself later.

| | Core (always) | Extras (optional) |
|---|---|---|
| Apps and CLI tools | [`config/Brewfile`](config/Brewfile) | [`config/Brewfile.extras`](config/Brewfile.extras) |
| VS Code extensions | [`config/vscode/extensions.txt`](config/vscode/extensions.txt): 8 | [`config/vscode/extensions-extras.txt`](config/vscode/extensions-extras.txt): packs |

Install all extras without prompts: `EXTRAS=1 ./bootstrap.sh --only "packages vscode"`

### Core

| Area | Tools | Why |
|---|---|---|
| **Terminal** | [Ghostty](https://ghostty.org), [tmux](https://github.com/tmux/tmux), [Starship](https://starship.rs), [zoxide](https://github.com/ajeetdsouza/zoxide), [fzf](https://github.com/junegunn/fzf), zsh autosuggestions and syntax highlighting, JetBrains Mono Nerd Font | Fast native terminal, sessions that survive, `z <dir>` jumps, **Ctrl‑R** history search |
| **Editor** | [VS Code](https://code.visualstudio.com) + 8 extensions | Claude Code, Copilot, Bicep, Terraform, Dev Containers, GitHub Actions, YAML, EditorConfig. Nothing else |
| **Git** | git (latest), [GitHub CLI](https://cli.github.com) `gh`, [delta](https://github.com/dandavison/delta) | PRs and Actions from the terminal; readable diffs |
| **Containers** | [Podman](https://podman.io), podman-compose | Docker-compatible, rootless, no licence fees. `docker` is aliased to `podman` |
| **Kubernetes** | kubectl, [Helm](https://helm.sh), [kubelogin](https://github.com/Azure/kubelogin) | Clusters, charts, Entra ID sign-in for AKS |
| **Azure** | Azure CLI `az`, [Azure Developer CLI](https://aka.ms/azd) `azd` | Manage Azure; `azd up` provisions and deploys whole apps |
| **IaC** | [Bicep](https://aka.ms/bicep), [Terraform](https://terraform.io), [OpenTofu](https://opentofu.org), [TFLint](https://github.com/terraform-linters/tflint) | Azure-native and multi-cloud IaC. OpenTofu is the open-source fork |
| **AI agents** | [Claude Code](https://claude.com/claude-code), [GitHub Copilot CLI](https://docs.github.com/copilot), [OpenCode](https://opencode.ai) | Three terminal coding agents. Use the one your team prefers |
| **Local models** | [Foundry Local](https://aka.ms/foundry-local) | Runs open models **on-device** on the Apple Silicon GPU. Private, offline, free |
| **Guardrails** | [gitleaks](https://github.com/gitleaks/gitleaks), [Trivy](https://trivy.dev), [pre-commit](https://pre-commit.com) | Catch secrets, IaC misconfigurations and CVEs before you push |
| **Runtimes** | [mise](https://mise.jdx.dev) (Node LTS, Python 3.13, tflint), [uv](https://docs.astral.sh/uv/), [direnv](https://direnv.net) | One version manager instead of nvm + pyenv + … |
| **Essentials** | jq, yq, ripgrep, fd | JSON/YAML wrangling and fast search, which agents use heavily too |

### Extras (optional)

| Tools | Why you might want them |
|---|---|
| Podman Desktop, k9s, lazygit | GUIs / terminal UIs for containers, Kubernetes and git |
| PowerShell (preview), ShellCheck, act | Azure scripting, shell linting, run GitHub Actions locally |
| bat, eza, btop, tldr, tree, wget | Nicer `cat` / `ls`, system monitor, short command examples (aliases switch on automatically if installed) |
| [Granola](https://www.granola.ai) | AI meeting notes |
| VS Code packs | Theme (Catppuccin), Git (GitLens, PRs), Containers & Kubernetes, Azure & scripting, Python, Web, Writing & quality |

## How it works

`bootstrap.sh` runs these steps in order. Each one is a small, readable script in [`scripts/`](scripts/) and **safe to re-run**.

| Step | What it does |
|---|---|
| `preflight` | Checks every prerequisite; installs Xcode Command Line Tools |
| `homebrew` | Installs Homebrew |
| `packages` | Installs `config/Brewfile`; offers the extras |
| `shell` | Links zsh, Ghostty, tmux and git-ignore config into your home folder |
| `git` | Sets your name and email, plus [sensible defaults](scripts/git.sh) (rebase on pull, auto-upstream, better diffs…) |
| `github` | Signs in to GitHub CLI; optionally creates an SSH key for auth **and signed commits** |
| `runtimes` | Installs Node, Python and tflint via mise |
| `podman` | Creates and starts the Podman VM, sized to your Mac |
| `vscode` | Adds the `code` command, links settings, installs the 8 core extensions; offers the packs |
| `macos` | *(asks first)* Dock, Finder and keyboard settings for developers; turns on the firewall |
| `ai` | Installs Claude Code; checks Copilot CLI, OpenCode and Foundry Local |
| `verify` | Health check of every tool and sign-in |

```bash
./bootstrap.sh --list                  # show steps
./bootstrap.sh --only vscode           # run one step
./bootstrap.sh --only "git github"     # run a few
./bootstrap.sh --skip macos            # everything except macOS settings
./bootstrap.sh --only verify           # health check anytime
```

**Built to be hard to break:**
- **Checks first.** Preflight stops before any change if your Mac doesn't qualify.
- **Idempotent.** Re-running skips what's already done.
- **Backs up.** Existing config files are moved to `~/.local/share/agentic-devops-setup/backup/<timestamp>/` before anything is replaced.
- **Logged.** Every run is saved to `~/.local/share/agentic-devops-setup/bootstrap-<timestamp>.log`.
- **Resumable.** If a step fails, it tells you the exact command to resume from that step.
- **Linked, not copied.** Config files are *symlinked* to this repo, so `git pull` updates your machine and `git diff` shows what you've changed.
- **CI-checked.** Every change is linted with ShellCheck and secret-scanned with gitleaks.
- **Supply-chain aware.** `main` is protected (pull requests + passing CI, no force-push), GitHub secret scanning and push protection are on, CI actions are pinned to commit SHAs and kept current by Dependabot, and the installer uses release tags.

---

## Bootstrap with Claude Code

Already have [Claude Code](https://claude.com/claude-code)? Let it drive the setup:

```bash
cd ~/Dev/agentic-devops-macos-setup
claude
```

Then type **`/bootstrap`** (or just *"set up my Mac"*). Claude reads [`CLAUDE.md`](CLAUDE.md) and the [bootstrap skill](.claude/skills/bootstrap/SKILL.md), runs preflight, works through each step, explains failures and fixes them with you. It hands you the interactive parts (passwords, GitHub sign-in, SSH passphrase).

---

## Agent instructions for your projects

AI agents work far better, and more safely, when each repo tells them the rules. [`templates/`](templates/) has a generic starter:

| File | Read by | What it does |
|---|---|---|
| [`AGENTS.md`](templates/AGENTS.md) | GitHub Copilot, OpenCode and most other agents | Project context, commands, and **DevOps safety rules**: plan but never apply, never delete cloud resources, never touch secrets, work on branches |
| [`CLAUDE.md`](templates/CLAUDE.md) | Claude Code | Imports `AGENTS.md`, so you maintain **one** set of rules for all agents |
| [`.claude/settings.json`](templates/.claude/settings.json) | Claude Code | Enforced guardrails: auto-allows `plan` / `validate` / `lint`; **asks** before `apply`, `azd up`, `kubectl apply/delete`, `git push`; **blocks** its file-reading tool from `.env`, keys, `*.tfvars` and state files, and blocks force-push. This is a guardrail, not a sandbox: shell commands can still reach those files, so keep real secrets out of the repo (Key Vault, a password manager) |

Add them to any repo (existing files are never overwritten):

```bash
cd ~/Dev/my-project
agent-init
```

Then fill in the `TODO`s in `AGENTS.md`: what the project is, and its test and lint commands.

---

## After installing

1. **Sign in to Azure:** `az login` then `azd auth login`
2. **Sign in to your AI agents:** run `claude`, `copilot` and `opencode` once each
3. **Try a local model:** `foundry model run phi-4-mini`
4. **Turn on VS Code Settings Sync** (account icon, bottom left) to back up your editor setup
5. **Log out and back in** so the key repeat settings apply

### Cheat sheet

| Do this | Type |
|---|---|
| Jump to a folder you've visited | `z <part-of-name>` |
| Search command history | **Ctrl‑R** |
| Find a file | **Ctrl‑T** |
| Git UI *(extras)* | `lg` |
| Kubernetes UI *(extras)* | `k9s` |
| Add agent rules to a repo | `agent-init` |
| Run containers | `docker run …` (it's Podman) |
| New tmux session / detach / reattach | `tmux new -s work` / **Ctrl‑a d** / `tmux a -t work` |
| tmux split side by side / top and bottom | **Ctrl‑a \|** / **Ctrl‑a -** |
| Explain a command | `tldr <command>` |

---

## Customising

| I want to… | Edit |
|---|---|
| Add or remove apps and tools | [`config/Brewfile`](config/Brewfile) or [`Brewfile.extras`](config/Brewfile.extras), then `./bootstrap.sh --only packages` |
| Add VS Code extensions | [`extensions.txt`](config/vscode/extensions.txt) or [`extensions-extras.txt`](config/vscode/extensions-extras.txt) |
| Change agent rules for every new repo | [`templates/`](templates/) |
| Change runtime versions | [`config/mise/config.toml`](config/mise/config.toml) |
| Add personal aliases or secrets | `~/.zshrc.local` (not tracked by git) |
| Change the Dock apps | the `for app in …` list in [`scripts/macos.sh`](scripts/macos.sh) |

**Fork this repo** for your team, adjust the Brewfile, and point `install.sh` at your fork.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| A step failed | Read the red message, fix it, then run the `./bootstrap.sh --only <step>` command it prints. Full log is in `~/.local/share/agentic-devops-setup/` |
| *"Rosetta"* error | Your terminal app is set to "Open using Rosetta". Uncheck it in Get Info |
| *"sudo: a terminal is required"* | Run from a real terminal window, not from a script or an IDE task |
| Homebrew *"untrusted tap"* | Run `./bootstrap.sh --only packages`; it trusts the official HashiCorp, Azure and Microsoft taps |
| Corporate proxy / VPN blocks downloads | Set `HTTPS_PROXY`, or disconnect from VPN for the install |
| `docker` tools can't find Podman | `podman machine start`, or accept the `podman-mac-helper` prompt in the `podman` step |
| Podman VM gone after reboot | `podman machine start`  |
| New shell settings not showing | Open a new Ghostty window, or run `exec zsh` |
| Something seems off | `./bootstrap.sh --only verify` |

---

## Undoing changes

- **Config files:** originals are in `~/.local/share/agentic-devops-setup/backup/<timestamp>/`. Delete the symlink and move the original back.
- **macOS settings:** `defaults import com.apple.dock ~/.local/share/agentic-devops-setup/backup/<timestamp>/com.apple.dock.plist` (same for `com.apple.finder`, `NSGlobalDomain`, `com.apple.screencapture`), then `killall Dock Finder`.
- **Apps and tools:** `brew uninstall <name>`, or `brew bundle cleanup --file config/Brewfile --force` to remove anything *not* in the Brewfile. ⚠️ Read its output without `--force` first.
- **Podman VM:** `podman machine rm`

---

## Related

- [**kodra-macos**](https://github.com/codetocloudorg/kodra-macos): Code to Cloud's turnkey installer with 40+ cloud-native tools. Use Kodra for a zero-touch install; use this repo to understand and customise every choice.
- [**windows_dev_setup**](https://github.com/codetocloudorg/windows_dev_setup): the Windows equivalent.

---

## Disclaimer

**Use at your own risk.** This project is provided **"AS IS", without warranty of any kind**, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and non-infringement. See the [LICENSE](LICENSE).

In plain English:

- These scripts **install software and change system settings** on your Mac. **Read them before running.** They are short and commented for that reason.
- **Back up your Mac** (Time Machine) before running on a machine you depend on.
- On a **company-managed Mac**, check with your IT or security team first. Some steps (firewall, Homebrew, SSH keys, AI tools) may conflict with corporate policy or device management.
- Third-party tools are installed from their publishers via Homebrew and **remain under their own licenses and terms**, including commercial terms for Terraform (BUSL), Claude Code, GitHub Copilot and Azure services. You are responsible for complying with them and for any cloud costs you incur.
- **AI coding agents can run commands and change files.** Review what they propose, keep secrets out of prompts, and follow your organisation's AI usage policy.
- Code to Cloud and contributors are **not liable** for any data loss, downtime, security incident, cost or other damage arising from use of this project.
- This is a community project and is **not affiliated with or endorsed by** Apple, Microsoft, GitHub, Anthropic, HashiCorp or any other vendor mentioned. All trademarks belong to their owners.

---

MIT © Code to Cloud
