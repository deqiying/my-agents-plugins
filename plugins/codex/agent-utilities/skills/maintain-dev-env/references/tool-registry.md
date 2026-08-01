# Tool Registry Workflow

Use this workflow when the shared desired tool set, direct-to-outer manager chains, install strategy, update ownership, version policy, check commands, or Node `postinstall` recovery list must be audited or changed.

The registry describes desired state, not one manager's inventory and not proof of installation. For example, an npm-installed CLI backed by mise-managed Node has `manager_chain: [npm, mise]`; it is not directly mise-managed.

## Files

- `tool-registry.yaml` is the curated registry.
- `scripts/export-mise-tools.ps1` and `scripts/export-mise-tools.sh` export sanitized mise state for comparison. They do not prove direct ownership for nested package managers.

Do not commit raw `mise ls --current --json` output because it can include local install and config paths.

## Workflow

1. Read `references/tool-registry.yaml`.
2. Inspect the current machine only when needed, using the direct manager first:
   - PowerShell 7 on Windows: `powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File scripts/manage-pwsh.ps1 -Action check`.
   - Windows: `powershell -ExecutionPolicy Bypass -File scripts/export-mise-tools.ps1`
   - macOS/Linux: `bash scripts/export-mise-tools.sh`
   - npm globals: `npm prefix --global`, `npm list --global --depth=0`, and direct command resolution.
3. Compare actual state with `id`, `manager_chain`, `install_strategy`, `update_owner`, `version_policy`, and `command`.
4. Add or update entries only when they are useful across agent development tasks.
5. Keep shared/global tools on `version_policy: latest`. Exact project versions belong in repository configuration.
6. Preserve the complete ownership chain: direct manager first, followed by outer runtime, version, or platform managers.
7. When changing an `[npm, mise]` entry with `install_strategy: npm-global`, synchronize the active global mise Node `postinstall` policy in the same task:
   - Use `mise config ls` and respect `MISE_GLOBAL_CONFIG_FILE`; do not assume a machine-specific path or edit a project config.
   - Build the recovery list from every qualifying entry's `package`, adding `@latest` when the version policy is `latest`.
   - Merge the list into the existing Node declaration while preserving unrelated Node options and unrelated `postinstall` commands.
   - If the global config is unavailable or outside the authorized scope, report the registry/config divergence as unfinished work.
8. Before upgrading mise-managed Node, inventory npm-global CLIs and confirm the recovery policy covers every qualifying entry. Verify the parsed Node declaration with `mise config ls`; do not reinstall Node only to test the hook.
9. Before removing a tool, search for skills or plugins that reference its command.

## Entry Rules

Each entry should include:

- `id`: stable logical id.
- `command`: expected command on PATH.
- `package`: native package id when required to build install/update commands; require it for qualifying `[npm, mise]` npm-global entries.
- `manager_chain`: direct-to-outer manager order; never collapse `[npm, mise]` to `[mise]`.
- `install_strategy`: provisioning strategy such as `winget-wix`, `mise`, `node-bundled`, `npm-global`, or `mise-npm-backend`.
- `update_owner`: the single manager allowed to update the active installation.
- `category`: `runtime`, `agent-tool`, `package-manager`, or `utility`.
- `version_policy`: `latest` for shared/global tools; exact project versions come from repository files.
- `check`: short verification commands.
- `notes`: durable notes without machine-local paths.

## Safety

- Do not add user names, home directories, install paths, or local config paths.
- Do not flatten nested ownership or change strategy merely because another manager can install the same package.
- Do not update a qualifying npm-global entry without synchronizing Node recovery or explicitly reporting why it remains divergent.
- Do not allow a built-in updater to create a second installation under another manager.
- Do not pin shared/global tools to the version observed on one machine.
- Use manager-specific runtime checks to prove installation; the registry alone is insufficient.
- Do not use `mise which <npm-global-cli>` as the primary diagnosis for a CLI owned by the active npm prefix.
