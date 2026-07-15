---
name: maintain-dev-tool-list
description: 'Use when an agent needs to maintain the shared developer tool registry for agent work, including direct and outer manager chains, install and update ownership, version policies, check commands, Node-scoped npm globals, synchronized mise Node postinstall recovery, and sanitized manager inventories.'
---

# Maintain Dev Tool List

## Role

Use this skill to maintain the tool registry that `$maintain-dev-env`, `$setup-dev-env`, `$manage-scoop`, `$manage-mise`, and `$manage-brew` use when checking, preparing, or repairing developer machines.

The registry describes shared/global desired state, not one manager's inventory. Keep direct ownership distinct from the outer runtime or version manager. For example, an npm-installed CLI backed by a mise-managed Node runtime has `manager_chain: [npm, mise]`; it is not directly managed by mise.

Shared tool and runtime version policies should default to `latest`. Exact versions belong in project-level config, not this shared registry.

## Registry Files

- `references/tool-registry.yaml` is the curated registry.
- `scripts/export-mise-tools.ps1` and `scripts/export-mise-tools.sh` export sanitized current mise tools for review. They do not prove direct ownership for tools installed by nested package managers.

Do not commit raw `mise ls --current --json` output, because it includes local install paths and config paths. Always sanitize paths to placeholders first.

## Maintenance Workflow

1. Read `references/tool-registry.yaml`.
2. Inspect the current machine only when needed, using the direct manager first:
   - Windows: `powershell -ExecutionPolicy Bypass -File scripts/export-mise-tools.ps1`
   - macOS/Linux: `bash scripts/export-mise-tools.sh`
   - For npm globals: run `npm prefix --global`, `npm list --global --depth=0`, and resolve the target command directly.
   - Treat `mise ls --current` as evidence for the outer mise layer or a declared mise backend, not as proof that mise is the direct package manager.
3. Compare current tools to the registry by `id`, `manager_chain`, `install_strategy`, `update_owner`, `version_policy`, and `command`.
4. Add or update entries only when they are useful across agent development tasks.
5. Keep shared/global tools on `version_policy: latest`, including language runtimes and globally configured agent tools. Do not copy the currently installed version into the registry as a pin.
6. Preserve the full ownership chain:
   - Put the direct package or tool manager first.
   - Append outer runtime, version, or platform managers in order.
   - Use `[npm, mise]` for an npm global CLI running under mise-managed Node, and `[mise]` only for a directly mise-managed tool or runtime.
7. When adding, updating, or removing an entry with `install_strategy: npm-global` and a `manager_chain` that starts with `[npm, mise]`, synchronize the active global mise config's Node `postinstall` policy in the same task:
   - Run `mise config ls`, respect `MISE_GLOBAL_CONFIG_FILE` when set, and identify the user-global config rather than assuming a machine-specific path. Do not edit a project config for this policy.
   - Build the recovery list from every qualifying registry entry's declared `package`, using `@latest` when `version_policy` is `latest`.
   - Merge the complete recovery list into the existing Node declaration, for example `node = { version = "latest", postinstall = "npm install --global <package-a>@latest <package-b>@latest" }`.
   - Preserve unrelated Node options and any `postinstall` commands or packages not governed by the registry. When removing an entry, remove only its declared package from the registry-managed recovery list.
   - If the global config is unavailable or outside the authorized scope, report the registry/config divergence as unfinished work instead of claiming synchronization.
8. Before upgrading mise-managed Node, inventory npm global CLIs and verify that the synchronized Node `postinstall` policy covers every qualifying registry entry. After editing, run `mise config ls` and inspect the parsed Node declaration. Do not reinstall Node only to test the hook; exercise it on the next authorized Node install or upgrade.
9. Before removing a tool, check whether any skill or plugin references its command.

## Entry Rules

Each registry entry should include:

- `id`: stable tool id, such as `node`, `onesearch`, or `github:flupkede/codesearch`.
- `command`: command expected on PATH.
- `package` (when applicable): native package id when it differs from the logical tool id or is needed to build install/update commands, such as `@openai/codex`. Require it for every qualifying `[npm, mise]` `npm-global` entry because it feeds the Node `postinstall` recovery list.
- `manager_chain`: ordered direct-to-outer managers. Do not collapse `[npm, mise]` to `[mise]`.
- `install_strategy`: how the desired installation is provisioned, such as `mise`, `node-bundled`, `npm-global`, or `mise-npm-backend`.
- `update_owner`: the one manager allowed to update the active installation. A CLI's built-in updater is valid only when it delegates to this owner and targets the resolved installation.
- `category`: `runtime`, `agent-tool`, `package-manager`, or `utility`.
- `version_policy`: use `latest` for shared/global tools. Project-specific exact versions should come from repository files such as `mise.toml`, `.tool-versions`, `go.mod`, `rust-toolchain.toml`, `Cargo.toml`, `package.json`, or `pyproject.toml`.
- `check`: short command list for verification.
- `notes`: only durable notes; no machine-local paths.

## Safety Rules

- Do not add real values like user names, home directories, install paths, or local config paths.
- Do not flatten nested ownership merely because an outer manager exposes the command or backend.
- Do not change `install_strategy` or `update_owner` just because another manager can install the same package.
- Do not update a qualifying npm-global registry entry without also synchronizing the global mise Node `postinstall` policy or explicitly reporting why that machine-level change could not be completed.
- Do not let a built-in updater create a second installation under a different manager. Check all resolved command paths after updates.
- Do not pin shared/global language runtimes or agent tools to the version observed on one machine.
- Do not use the registry as proof that a tool is installed. It is desired state; verify the actual machine with manager-specific commands.
- Do not use `mise which <npm-global-cli>` as the primary diagnosis for a CLI owned by the active Node npm prefix. Use the npm prefix, npm global package list, and direct command resolution first.
