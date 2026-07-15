# mise Notes

Use placeholders in persistent text:

- `<GLOBAL_MISE_CONFIG>` for the global config file.
- `<LOCAL_MISE_CONFIG>` for a project config under `<PROJECT_ROOT>`.
- `<MISE_DATA_DIR>` for the data directory containing installed tools.
- `<PROJECT_ROOT>` for the current repository or project being prepared.

## Read-Only Checks

```powershell
mise --version
mise doctor
mise ls --current --json
mise ls --installed
mise outdated --json
```

For a CLI installed by npm under the active mise-managed Node, inspect the direct manager before mise-specific lookup commands:

```powershell
npm prefix --global
npm list --global --depth=0
Get-Command <CLI> -All
<CLI> --version
```

On macOS or Linux, replace `Get-Command <CLI> -All` with `command -v -a <CLI>` when supported, or `type -a <CLI>`.

`mise ls --current` confirms the active Node runtime and any explicitly declared mise backend tools. It does not list every package inside the active Node npm global prefix. Do not use `mise which <CLI>` as the primary test for an `npm-global` installation.

## Manager And Update Ownership

- Read `manager_chain` from direct to outer manager. `[npm, mise]` means npm owns the package and mise supplies the outer Node/runtime layer.
- Prefer a native package manager such as npm, pnpm, Cargo, Go, pipx, or uv when it is the intended direct lifecycle owner.
- Follow `install_strategy` and `update_owner` separately. Do not let a CLI self-updater silently create a copy under another manager.
- Before and after an update, resolve all copies of the command and confirm the updated version belongs to the declared owner.

For an npm-global CLI whose built-in updater delegates to npm, allow that updater only when the resolved command is inside the active `npm prefix --global`. Otherwise use the declared manager command.

## Preserve npm CLIs Across Node Upgrades

Each mise-managed Node version has a separate npm global prefix. Packages installed with `npm install --global` under one Node version are not migrated to a newly installed Node version.

Before upgrading Node:

```powershell
npm prefix --global
npm list --global --depth=0
Get-Command onesearch,codex,officecli,opencli -All
```

After explicit approval, restore any missing package in the current active Node prefix with its direct manager:

```powershell
npm install --global <PACKAGE>@latest
```

This operation needs network access and runs the package's npm lifecycle scripts. Install only the missing or requested package; do not reinstall the entire list merely because one CLI is absent.

For curated CLIs that should remain npm-owned, use the Node tool-level `postinstall` hook in `<GLOBAL_MISE_CONFIG>`:

```toml
[tools]
node = { version = "latest", postinstall = "npm install --global onesearch@latest @openai/codex@latest @officecli/officecli@latest @jackwener/opencli@latest" }
```

Merge `postinstall` into the existing `node` declaration and preserve any existing Node options. Do not add a second `node` key or replace project-specific settings blindly.

The hook runs after mise installs a new Node version; it does not retroactively repair an already installed Node version. Install missing packages once with npm after adding the policy, or apply the policy during the next approved Node installation.

After upgrading Node:

```powershell
npm prefix --global
npm list --global --depth=0
Get-Command onesearch,codex,officecli,opencli -All
onesearch --version
codex --version
officecli --version
opencli --version
```

Treat multiple mutable global copies as a manager conflict. A lower-precedence product-bundled fallback may coexist when it is not the selected update target; classify it explicitly instead of deleting it. Keep the declared npm-global copy and remove or migrate another mutable copy only after explicit approval.

## mise npm Backend Exception

The mise `npm:` backend installs an npm ecosystem package as a separate mise tool and records it in mise config. This decouples the tool directory from the active Node npm global prefix, but changes the lifecycle owner to mise and can conflict with CLI self-updaters that call `npm install --global`.

Inspect package lifecycle scripts before choosing this exception. The mise npm backend uses more restrictive lifecycle-script defaults than direct npm, so packages whose npm `postinstall` fetches a native binary may require extra approval/configuration or may not install correctly under the backend defaults.

Use this only after an explicit strategy choice and duplicate check:

```powershell
mise use --global "npm:<PACKAGE>@latest"
mise upgrade "npm:<PACKAGE>"
```

When using this strategy, record `install_strategy: mise-npm-backend` and `update_owner: mise`. Do not also keep an npm-global copy.

The `npm:` backend's default `npm.package_manager=auto` setting may use another compatible installer such as aube when available. If the actual installer must be npm, verify or explicitly configure that setting rather than assuming the backend name proves which executable ran.

## Deprecated Default Package File

Do not adopt `<HOME>/.default-npm-packages` as the durable solution. Current mise documentation says default package files will start warning in `2026.11.0` and will be removed in `2027.11.0`. Prefer a Node `postinstall` hook for packages that must live in every Node npm global prefix, or an explicitly chosen mise backend strategy.

Official references:

- `https://mise.jdx.dev/lang/node.html#default-node-packages`
- `https://mise.jdx.dev/dev-tools/backends/npm.html`

## Common Apply Commands

Run only after explicit approval:

```powershell
mise use --global node@latest
mise use --global go@latest
mise install
mise upgrade --dry-run
mise upgrade node
```

Use `mise use --global` for user-wide defaults and `mise use` from `<PROJECT_ROOT>` only when the project should carry a checked-in or local mise config.
