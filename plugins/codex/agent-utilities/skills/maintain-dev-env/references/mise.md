# mise Workflow

Use this workflow for mise itself, directly mise-managed runtimes or tools, project version mismatches, and the outer mise layer in nested manager chains. It also owns diagnosis and durable recovery of npm-global CLIs after a mise-managed Node change.

## Contents

- [Scope And Ownership](#scope-and-ownership)
- [Default Workflow](#default-workflow)
- [Project Config Trust](#project-config-trust)
- [Project-Level Rust Proxy Recovery](./mise-rust.md#project-level-rust-proxy-recovery)
- [Path Placeholders](#path-placeholders)
- [Read-Only Checks](#read-only-checks)
- [Mise-Managed Developer Utilities](#mise-managed-developer-utilities)
- [Java, Maven, And mvnd](#java-maven-and-mvnd)
- [Manager And Update Ownership](#manager-and-update-ownership)
- [Preserve npm CLIs Across Node Upgrades](#preserve-npm-clis-across-node-upgrades)
- [mise npm Backend Exception](#mise-npm-backend-exception)
- [Deprecated Default Package File](#deprecated-default-package-file)
- [Script Actions](#script-actions)
- [Safety](#safety)

## Scope And Ownership

- On Windows, install or update Scoop-owned `mise` through the Scoop workflow; do not use `mise self-update`.
- On macOS, update Homebrew-owned `mise` through the Homebrew workflow; otherwise preserve the existing install source.
- On Linux, confirm the install source before running any remote installer.
- Read `tool-registry.yaml` before changing a registered tool. Keep `manager_chain`, `install_strategy`, and `update_owner` distinct.
- Use mise commands directly only for entries whose manager chain begins with `mise`.
- For project-level Rust with `MISE_CARGO_HOME` or `MISE_RUSTUP_HOME`, load [mise-rust.md](./mise-rust.md#project-level-rust-proxy-recovery) for the dedicated diagnosis, recovery, and verification workflow.
- For `[npm, mise]`, use npm for `npm-global`; use a mise npm backend only after an explicit strategy decision and duplicate check.
- Treat registered `java`, `maven`, and `mvnd` as separate direct mise-managed tools. The Maven registry id is `maven`, while its primary command is `mvn`.
- Treat shared/global Rust as mise-managed. If `rustc` or `cargo` resolves to rustup or `<HOME>/.cargo/bin`, report a manager mismatch unless a project explicitly requires rustup.
- Use lowercase `officecli` as the canonical command. If it resolves to a different strategy than the registry declares, report the mismatch before installing another copy.
- Manage registered developer utilities such as `ast-grep`, `bat`, `delta`, `difftastic`, `fd`, `fzf`, `gh`, `jq`, `just`, `ripgrep`, `sd`, and `yq` directly through mise. On Windows, keep `sqlite` Scoop-owned unless a mise Conda backend has passed an actual `sqlite3` database query through its shim.

## Default Workflow

1. Run the platform-appropriate `manage-mise` script in check mode.
2. Inspect `mise --version`, `mise ls --current --json`, and `mise ls --installed`.
3. Resolve the target command and inspect its direct manager. For npm globals, inspect the active npm prefix and package list first.
4. Follow the declared install strategy:
   - Global mise default: `mise use --global <tool>@latest`.
   - Existing project config: `mise use <tool>@<project-version>` from `<PROJECT_ROOT>`.
   - Install-only or temporary use: `mise install <tool>@<version>` and `mise exec <tool>@<version> -- <command>`.
   - npm global: install with npm under the active Node and synchronize the Node `postinstall` recovery policy.
5. Inspect `mise upgrade --dry-run` and `mise outdated --json` before a mise-owned update.
6. Apply only after explicit approval.
7. Verify the complete manager chain, all command paths, target version, and original blocked command.

For project work, follow repository-declared versions. For shared/global tools, use `latest` unless the user explicitly requests a global pin.

## Project Config Trust

`mise` can refuse to load a project config that uses templates, `[env]`, tool options, or other active features until it is trusted. Treat an untrusted-config error after creating or changing `<LOCAL_MISE_CONFIG>` as a project-config trust blocker, not as a Go, shim, or package-manager failure.

First confirm the project root and inspect the exact config created or changed in the current task. Then check trust state:

```powershell
mise trust --show
```

When the current task created or changed that reviewed project config, it is authorized to trust only that file without a separate confirmation:

```powershell
mise trust --yes <LOCAL_MISE_CONFIG>
```

Re-run the original blocked command after trust, for example `mise exec -- go version` or the project's intended build/test command. Do not use `mise trust --all`, which includes parent and descendant configs. If the config pre-existed, was not reviewed in the current task, resolves outside `<PROJECT_ROOT>`, or a different config is reported as untrusted, stop and request explicit approval before trusting it.

## Path Placeholders

Use these placeholders in persistent text:

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

## Mise-Managed Developer Utilities

Use `tool-registry.yaml` as the authority for the complete utility set and expected command names. The shared/global tools in this group follow `latest` and are managed with `mise use --global <tool>@latest` or `mise upgrade <tool>` after explicit approval.

Before moving a Windows utility from Scoop to mise:

1. Confirm `mise registry <tool>` resolves to an intended backend and classify the complete manager chain.
2. Install the mise copy first and verify its direct executable with `mise which <command>` plus the registry check command.
3. Remove the exact Scoop package only after the command resolves to the mise shim. Do not migrate Scoop, Git, or another package merely because it is adjacent to the utility set.

For non-interactive source inspection, use `bat -pp -- <path>` for complete text and `bat -ppn -r <start>:<end> -- <path>` for a numbered range; use `rg -n` or `rg -n -C <N>` for search plus surrounding context. `fzf` is interactive and should not be used as an automation primitive, while `sd` is a replacement tool rather than a read-only file viewer.

## Java, Maven, And mvnd

Read the Java/Maven project declarations listed in `SKILL.md` before using the global defaults. Treat a Maven wrapper as project-owned: do not replace its declared distribution merely to match global `maven`.

Build global install or update specs from `tool-registry.yaml`. Before changing these tools, verify their live registry mappings, the Java shorthand vendor, active versions, and every resolved copy:

```powershell
mise registry java
mise registry maven
mise registry mvnd
mise settings get java.shorthand_vendor
mise ls java --json
mise ls maven --json
mise ls mvnd --json
Get-Command java,javac,mvn,mvnd -All
```

- `java@latest` and `java@<major>` are shorthands whose vendor comes from `java.shorthand_vendor`; they are not equivalent to `temurin-<major>`, `zulu-<major>`, or another vendor-qualified spec. The shared/global registry intentionally allows `latest` to change the Java major, but preserve the configured vendor and report patch-stream freshness concerns instead of switching vendors silently.
- `maven` and `mvnd` are independent mise tools. Verify both `mvn` and `mvnd`; do not assume the mvnd distribution replaces the selected standalone Maven command.
- An activated mise shell should select the mise shims and update `JAVA_HOME`. On Windows, compare `JAVA_HOME`, `MAVEN_HOME`, and `MVND` at Process, User, and Machine scopes because a current process can retain stale values after persistent configuration changes. On macOS/Linux, inspect the current environment and shell startup files. Do not delete old installations or edit persistent environment variables without explicit approval.
- `mvn --version` must report the intended Java runtime, not merely a healthy Maven binary. Verify it after activation or with `mise exec`.
- `mvnd --version` can initialize daemon state and may hang or emit no captured stdout in a restricted non-interactive shell. Use a bounded timeout. If the probe cannot provide output, preserve its exit status and verify `mise ls mvnd --json`, `mise which mvnd`, and the installed executable; rerun in an ordinary interactive shell when runtime output is required.

After an authorized change, verify the complete runtime combination:

```powershell
mise which java
mise which javac
mise which mvn
mise which mvnd
java -version
javac -version
mvn --version
mvnd --version
```

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
mise use --global java@latest maven@latest mvnd@latest
mise install
mise upgrade --dry-run
mise upgrade node
```

Use `mise use --global` for user-wide defaults and `mise use` from `<PROJECT_ROOT>` only when the project should carry a checked-in or local mise config.

## Script Actions

```powershell
powershell -ExecutionPolicy Bypass -File scripts/manage-mise.ps1 -Action check
powershell -ExecutionPolicy Bypass -File scripts/manage-mise.ps1 -Action install -Tools node@latest,go@latest -Global -Apply
powershell -ExecutionPolicy Bypass -File scripts/manage-mise.ps1 -Action install -Tools java@latest,maven@latest,mvnd@latest -Global -Apply
powershell -ExecutionPolicy Bypass -File scripts/manage-mise.ps1 -Action update -Tools node,python -Apply
```

```bash
bash scripts/manage-mise.sh check
bash scripts/manage-mise.sh install --global --apply node@latest go@latest
bash scripts/manage-mise.sh install --global --apply java@latest maven@latest mvnd@latest
bash scripts/manage-mise.sh update --apply node python
```

`-Apply` or `--apply` is required for install and update. The scripts reject `npm:` backend specs by default; use `-AllowBackend` or `--allow-backend` only for an explicitly approved backend migration.

## Safety

- Do not use `mise use` in a repository until the target config file is clear because it can write `mise.toml`.
- Do not use `mise trust --all`. Only `mise trust --yes <LOCAL_MISE_CONFIG>` is pre-authorized when the current task created or changed that reviewed project config.
- Do not update all tools by default, prune without a separate explicit request, or use `mise self-update` for a package-manager-owned copy.
- Do not run an npm-based CLI self-updater when the resolved command is owned by a mise npm backend.
- Do not install a native-manager CLI through a mise backend merely because mise exposes that backend.
- Do not adopt `.default-npm-packages` as a durable new solution; use Node `postinstall` or an explicitly selected backend strategy.
