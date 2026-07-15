---
name: manage-mise
description: 'Use when an agent needs to check, install, update, pin, or troubleshoot mise-managed runtimes and directly managed tools, the outer mise layer for nested package managers, or Node upgrades that change npm global prefixes and make npm-installed CLIs disappear. Use for manager-chain diagnosis, durable npm CLI reinstalls, and mise backend ownership across Windows, macOS, or Linux.'
---

# Manage Mise

## Role

Use this skill for mise itself, directly mise-managed runtimes or tools, and the outer mise layer in a nested manager chain. This skill is responsible for version-manager workflows: checking current tools, adding tools to global or project config, installing missing tools, upgrading tracked tools, and pruning unused versions after explicit approval.

Do not infer direct ownership from a mise shim, a `mise ls` entry, or an `npm:` backend spec. Read the registry's `manager_chain`, `install_strategy`, and `update_owner` first. For example, `[npm, mise]` means npm directly owns the CLI while mise supplies the outer runtime or lifecycle layer.

Prefer the native package manager as the direct lifecycle owner when one exists. Do not use a mise ecosystem backend as the default repair for a missing native-manager CLI, because mixing strategies can create multiple resolved copies.

Do not write real `mise` config or install paths into persistent text. Use `<GLOBAL_MISE_CONFIG>`, `<LOCAL_MISE_CONFIG>`, `<PROJECT_ROOT>`, and `<MISE_DATA_DIR>`.

## Manager Ownership

- Windows: if `mise` is missing, route to `$manage-scoop` first. If `mise` was installed through Scoop, update `mise` with Scoop, not `mise self-update`.
- macOS: if Homebrew owns `mise`, update `mise` through `$manage-brew`; otherwise follow the user's existing install source.
- Linux: use Bash checks and confirm the install source before running a remote installer.
- Tools already listed in `$maintain-dev-tool-list` should stay with their declared manager chain, install strategy, and update owner unless the user approves migration.
- Use mise commands directly for entries whose manager chain begins with `mise`.
- For `[npm, mise]`, follow `install_strategy`: use npm for `npm-global`, or mise for `mise-npm-backend`. Do not describe either strategy as unqualified direct mise ownership.
- Default npm-based CLIs to `npm-global` with `update_owner: npm`. Use `mise-npm-backend` only after an explicit strategy decision and a duplicate-installation check.
- A CLI self-updater may run only when it delegates to the declared `update_owner` and updates the resolved installation. Otherwise use the declared manager command and avoid creating a second copy.
- Rust should be managed by mise for shared/global agent environments. If `rustc` or `cargo` resolves to rustup or `<HOME>/.cargo/bin`, treat it as a manager mismatch unless a project explicitly requires rustup.
- OfficeCLI's canonical command is lowercase `officecli`. The registry prefers its npm package; if an existing command resolves to a mise GitHub backend, report the strategy mismatch and require an explicit migration decision before installing another copy.

## Default Workflow

1. Run check mode first:
   - Windows: `powershell -ExecutionPolicy Bypass -File scripts/manage-mise.ps1 -Action check`
   - macOS/Linux: `bash scripts/manage-mise.sh check`
2. Inspect active mise state:
   - `mise --version`
   - `mise ls --current --json`
   - `mise ls --installed`
3. Resolve the target command and inspect its direct manager. For npm globals, run `npm prefix --global`, `npm list --global --depth=0`, and direct command resolution before using mise-specific lookup commands.
4. For missing tools, follow the declared install strategy:
   - Direct mise global: `mise use --global <tool>@latest`.
   - Direct mise project: `mise use <tool>@<project-version>` from `<PROJECT_ROOT>`.
   - Direct mise install-only: `mise install <tool>@<version>`.
   - npm global: use npm under the active mise-managed Node, then preserve the package in the Node `postinstall` policy.
   - mise npm backend exception: only after explicit approval, use `mise use --global "npm:<package>@latest"`, set `update_owner: mise`, and avoid npm-based self-updaters for that installation.
5. For mise-owned updates, prefer dry-run first:
   - `mise upgrade --dry-run`
   - `mise outdated --json`
6. Apply install/update only after explicit user approval.
7. Verify the full chain: manager state, all resolved command paths, target version, and the original failed command.

## Node And npm CLI Boundary

- Each mise-managed Node version has its own npm global prefix. `npm install --global` packages do not migrate automatically when Node changes.
- Diagnose a missing npm CLI with `npm prefix --global`, `npm list --global --depth=0`, and direct command resolution. Use `mise ls --current` only to confirm the Node runtime or an explicitly declared npm backend.
- For `npm-global` tools that should retain npm-based self-updates, use a Node tool-level `postinstall` policy to reinstall the curated package list after each new Node installation.
- Use `mise-npm-backend` only as an intentional exception. Set mise as the update owner, remove or avoid the npm-global copy, and do not run a self-updater that writes into the active Node npm prefix.
- Read `references/mise.md` before changing Node or npm CLI policy. It documents the supported strategies, command examples, and the deprecation boundary for `.default-npm-packages`.

## Project Version Mismatches

When `$maintain-dev-env` finds that a project requires a different runtime or tool version than the active global command, install or activate the project-required version precisely. For example, if the active Go command is `1.26.1` and the project requires `1.26.4`, prefer `mise install go@1.26.4` and verify with `mise exec go@1.26.4 -- go version` before rerunning the original command.

If the repository already has `mise.toml` or `.tool-versions`, follow that project config. If it does not, avoid writing new project config until the target file and intent are clear; use install-only or temporary `mise exec` execution first.

For global language and agent-tool configuration, use `latest` by default. Use exact versions only when they come from project-level configuration or an explicit user request to pin a global tool. This version policy does not override the registry's install strategy or update owner.

## Script Actions

```powershell
powershell -ExecutionPolicy Bypass -File scripts/manage-mise.ps1 -Action check
powershell -ExecutionPolicy Bypass -File scripts/manage-mise.ps1 -Action install -Tools node@latest,go@latest -Global -Apply
powershell -ExecutionPolicy Bypass -File scripts/manage-mise.ps1 -Action update -Tools node,python -Apply
```

```bash
bash scripts/manage-mise.sh check
bash scripts/manage-mise.sh install --global --apply node@latest go@latest
bash scripts/manage-mise.sh update --apply node python
```

`-Apply` or `--apply` is required for install and update.

The scripts reject `npm:` backend specs by default. Pass `-AllowBackend` or `--allow-backend` only for an explicitly approved backend migration after checking for existing npm-global and other mutable copies.

## Safety Rules

- Do not use `mise use` in a repository until the target config file is clear, because it can write `mise.toml`.
- Do not update all tools by default. Show `mise upgrade --dry-run` first.
- Do not prune without a separate explicit user request.
- Do not use `mise self-update` when `mise` is package-manager-owned.
- Do not run an npm-based CLI self-updater when the resolved command is owned by a mise npm backend.
- Do not install a native-manager CLI through a mise backend merely because mise can expose that backend.
- Do not treat `.default-npm-packages` as a durable new solution; use the supported Node `postinstall` policy or an explicit npm backend strategy.
