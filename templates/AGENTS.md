# AGENTS.md

Instructions for AI coding agents (Claude Code, GitHub Copilot, OpenCode, and others) working in this repository.
Copy this file into your project root and fill in the `TODO` sections. Delete anything that doesn't apply.

## Project

TODO: one or two sentences on what this repo is and who uses it.

- **Cloud / platform:** TODO (e.g. Azure, AKS, Container Apps)
- **IaC:** TODO (Bicep / Terraform / OpenTofu), lives in `TODO/`
- **App code:** TODO (language, framework), lives in `TODO/`
- **CI/CD:** TODO (e.g. GitHub Actions in `.github/workflows/`)

## Commands

```bash
# TODO: replace with this repo's real commands
make test        # run tests
make lint        # lint everything
```

Run the tests and linters before saying a change is done.

## Infrastructure safety

- **Never apply or destroy infrastructure.** You may run `plan`, `what-if` and `validate`. A human runs `apply` / `deploy` / `destroy`.
  - Terraform/OpenTofu: `terraform plan` ✅  `terraform apply` ❌
  - Bicep: `az deployment group what-if` ✅  `az deployment group create` ❌
  - azd: `azd provision --preview` ✅  `azd up` / `azd down` ❌
- **Never delete cloud resources** (`az … delete`, `kubectl delete`, `helm uninstall`) unless the user explicitly asks in this session.
- Check which subscription / cluster you're pointed at before running any cloud command: `az account show`, `kubectl config current-context`.
- Prefer changing IaC over changing resources by hand in the portal or CLI.

## Secrets

- Never read, print or commit `.env` files, keys, certificates or connection strings.
- Use managed identities and Key Vault references, not secrets in code or config.
- If you find a secret in the code, stop and tell the user. Don't move it around.

## Git

- Small, focused commits with clear messages (what and why).
- Work on a branch; never push to `main` directly or force-push.
- Don't rewrite history that has been pushed.

## Code style

- Match the surrounding code: naming, comments, structure.
- Don't add dependencies without saying why.
- Keep changes scoped to the task. Mention other problems you notice instead of fixing them unasked.

## When unsure

Ask. A question is cheaper than a wrong change to production infrastructure.
