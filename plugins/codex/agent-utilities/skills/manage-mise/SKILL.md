---
name: manage-mise
description: 'Use when an agent needs to check, install, update, pin, or troubleshoot mise-managed developer runtimes and tools such as Node, Go, Python, uv, pnpm, Codex CLI, codesearch, OfficeCLI, and doggo across Windows, macOS, or Linux.'
---

# Manage Mise

## Role

Use this skill for mise itself and for tools managed by mise. This skill is responsible for version-manager workflows: checking current tools, adding tools to global or project config, installing missing tools, upgrading tracked tools, and pruning unused versions after explicit approval.

Do not write real `mise` config or install paths into persistent text. Use `<GLOBAL_MISE_CONFIG>`, `<LOCAL_MISE_CONFIG>`, `<PROJECT_ROOT>`, and `<MISE_DATA_DIR>`.

## Manager Ownership

- Windows: if `mise` is missing, route to `$manage-scoop` first. If `mise` was installed through Scoop, update `mise` with Scoop, not `mise self-update`.
- macOS: if Homebrew owns `mise`, update `mise` through `$manage-brew`; otherwise follow the user's existing install source.
- Linux: use Bash checks and confirm the install source before running a remote installer.
- Tools already listed in `$maintain-dev-tool-list` should stay with their declared manager unless the user approves migration.

## Default Workflow

1. Run check mode first:
   - Windows: `powershell -ExecutionPolicy Bypass -File scripts/manage-mise.ps1 -Action check`
   - macOS/Linux: `bash scripts/manage-mise.sh check`
2. Inspect active tools:
   - `mise --version`
   - `mise ls --current --json`
   - `mise ls --installed`
3. For missing tools, decide whether to write global config or project config:
   - Global: `mise use --global <tool>@<version>`
   - Project: `mise use <tool>@<version>` from `<PROJECT_ROOT>`
   - Install-only: `mise install <tool>@<version>`
4. For updates, prefer dry-run first:
   - `mise upgrade --dry-run`
   - `mise outdated --json`
5. Apply install/update only after explicit user approval.
6. Verify with `mise ls --current`, command resolution, and each target tool's version command.

## Project Version Mismatches

When `$maintain-dev-env` finds that a project requires a different runtime or tool version than the active global command, install or activate the project-required version precisely. For example, if the active Go command is `1.26.1` and the project requires `1.26.4`, prefer `mise install go@1.26.4` and verify with `mise exec go@1.26.4 -- go version` before rerunning the original command.

If the repository already has `mise.toml` or `.tool-versions`, follow that project config. If it does not, avoid writing new project config until the target file and intent are clear; use install-only or temporary `mise exec` execution first.

## Script Actions

```powershell
powershell -ExecutionPolicy Bypass -File scripts/manage-mise.ps1 -Action check
powershell -ExecutionPolicy Bypass -File scripts/manage-mise.ps1 -Action install -Tools node@latest,go@1.26.1 -Global -Apply
powershell -ExecutionPolicy Bypass -File scripts/manage-mise.ps1 -Action update -Tools node,python -Apply
```

```bash
bash scripts/manage-mise.sh check
bash scripts/manage-mise.sh install --global --apply node@latest go@1.26.1
bash scripts/manage-mise.sh update --apply node python
```

`-Apply` or `--apply` is required for install and update.

## Safety Rules

- Do not use `mise use` in a repository until the target config file is clear, because it can write `mise.toml`.
- Do not update all tools by default. Show `mise upgrade --dry-run` first.
- Do not prune without a separate explicit user request.
- Do not use `mise self-update` when `mise` is package-manager-owned.
