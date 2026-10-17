---
name: bootstrap
description: Set up this Mac as an Agentic DevOps workstation using this repo's bootstrap scripts. Use when the user says "set up my Mac", "bootstrap", "run the setup", or asks to install or repair the dev environment.
---

# Bootstrap this Mac

Guide the user through `./bootstrap.sh` one step at a time so failures are caught and explained.

1. Run `./bootstrap.sh --only preflight`. If it fails, explain the fix in plain language and stop until it's resolved.
2. Tell the user up front which steps need them at the keyboard: `homebrew` and `packages` (Mac password), `github` (browser sign-in, SSH passphrase), `macos` (asks before changing settings; password for firewall).
   - Interactive steps need a real TTY. For those, ask the user to run them themselves with the `!` prefix, e.g. `! ./bootstrap.sh --only github`.
3. Run the non-interactive steps yourself, one at a time, in this order: `shell git runtimes podman vscode ai`. For `git`, if no identity is set, ask the user for their name and email and pass them as `GIT_NAME=… GIT_EMAIL=…`.
4. After each step, read the output. On failure, check the log in `~/.local/share/agentic-devops-setup/`, diagnose, propose a fix, and re-run only that step.
5. Finish with `./bootstrap.sh --only verify` and summarise: what's installed, anything that needs attention, and the "After installing" list from README.md.

Never run `sudo` yourself, never skip preflight, and never edit files in `config/` to work around a failure without telling the user.
