---
name: maintain-dev-env
description: 'Use as the broad main guidance when an agent encounters or anticipates local developer environment work during any task, not only when the user asks for setup. Use for missing commands, PATH or shim issues, nested package-manager ownership, duplicate CLI copies, Node upgrades that change npm global prefixes, project/runtime version mismatches, or toolchain install, update, pin, repair, and temporary execution before building, testing, generating, or debugging.'
---

# Maintain Dev Env

## Role

Use this as the broad coordinator for local developer environment maintenance discovered while doing other work. Trigger it when the task is blocked or may be misled by a missing command, wrong runtime version, stale shim, package-manager ownership issue, PATH problem, or mismatch between a project-declared version and the active environment.

For user-requested machine setup, full environment audits, or "prepare this machine" requests, route to `$setup-dev-env`. For actual manager work, preserve the registry's direct manager and use `$manage-scoop`, `$manage-mise`, `$manage-brew`, or `$maintain-dev-tool-list` for their declared layer.

## Default Workflow

1. Identify whether the environment is relevant to the current task:
   - A command is missing or resolves to an unexpected path.
   - A build, test, generator, or CLI failed because a tool is absent, too old, too new, or from the wrong manager.
   - The project declares a tool version that differs from the active command version.
2. Read project version evidence before trusting global tools:
   - Go: `go.mod` `go` and `toolchain` directives, plus repository `mise.toml` or `.tool-versions`.
   - Rust: `rust-toolchain`, `rust-toolchain.toml`, `Cargo.toml` `rust-version`, plus repository `mise.toml` or `.tool-versions`.
   - Node: `package.json` `engines` and `packageManager`, `.node-version`, `.nvmrc`, `mise.toml`, `.tool-versions`.
   - Python: `pyproject.toml` `requires-python`, `.python-version`, `uv.lock`, `mise.toml`, `.tool-versions`.
   - Other tools: repository docs, lockfiles, CI configs, and checked-in tool manager files.
3. Inspect the active environment with real commands:
   - Windows: `Get-Command <tool> -All`, `<tool> --version`, `mise ls --current --json` when available.
   - macOS/Linux: `command -v -a <tool>`, `<tool> --version`, `mise ls --current --json` when available.
   - npm globals: `npm prefix --global` and `npm list --global --depth=0` before mise-specific command lookup.
4. Compare required and active versions. Report the exact source of the requirement, every resolved command path, and the direct-to-outer manager chain.
5. Choose the smallest corrective path:
   - Follow `manager_chain`, `install_strategy`, and `update_owner` from `$maintain-dev-tool-list`.
   - Prefer the native package manager as direct owner. Use `$manage-mise` for entries beginning with `mise` and for the outer runtime layer of nested chains.
   - If an npm-global CLI disappeared after a Node change, reinstall it with npm under the active Node and add or repair the Node `postinstall` reinstall policy. Do not default to a mise npm backend.
   - If shared/global Rust commands resolve to rustup or `<HOME>/.cargo/bin`, report a manager mismatch and prefer migrating Rust to mise management before treating it as healthy.
   - On Windows, if `mise` is missing or Scoop owns it, use `$manage-scoop`.
   - On macOS, if Homebrew owns the tool or is the better native manager, use `$manage-brew`.
   - If the shared desired tool set is wrong or missing an entry, use `$maintain-dev-tool-list`.
6. Prefer task-local or project-aware execution before changing global state:
   - If the project already has `mise.toml` or `.tool-versions`, install the required version and let the project config select it.
   - If no project config exists, prefer an install-only or temporary execution path such as `mise install <tool>@<version>` followed by `mise exec <tool>@<version> -- <command>`.
   - For shared/global tool maintenance, use the latest available version by default. Do not turn a project-required version into a global pin unless the user explicitly asks for that machine policy.
   - Do not write `mise.toml`, `.tool-versions`, shell profile files, or PATH changes unless the target file and intent are clear.
7. After any change, verify direct and outer manager state, all resolved command paths, target tool version, and the original failed or blocked project command. Treat multiple mutable global copies under different managers as unresolved until one lifecycle owner is chosen; classify lower-precedence product-bundled fallbacks separately.

## Version Mismatch Pattern

When the active tool and project requirement differ, treat the project requirement as the default target for that project. For example, if `go version` reports `1.26.1` but `go.mod` or `toolchain` requires `1.26.4`, plan a precise install or activation such as `mise install go@1.26.4`, then verify with `mise exec go@1.26.4 -- go version` before rerunning the original Go command.

Do not "fix" the project by downgrading its declared version to match the global machine. Only propose changing project requirements when the user asked for a compatibility decision or the repository evidence clearly shows the declaration is wrong.

This project-specific precision does not change shared/global version policy: global language runtimes and agent tools should use the latest available version unless the user explicitly requests a fixed global version.

## Safety Rules

- Run read-only checks first whenever possible.
- Do not run remote installer commands, package-manager updates, `mise upgrade`, `scoop update`, `brew upgrade`, shell profile edits, PATH changes, or prune operations without explicit user approval.
- Do not install the same tool through multiple managers unless the user intentionally wants that layout.
- Do not use a mise ecosystem backend as the default installation path when a native package manager is the declared direct owner.
- Do not run a built-in updater unless it delegates to the declared `update_owner` and targets the resolved active copy.
- Keep persistent text sanitized. Replace local user directories with placeholders before writing tracked docs, logs, examples, or registry files.
- Treat registry entries as desired state, not proof that a tool is installed.

## Reporting

Return a compact maintenance report with:

- The environment issue and why it matters to the current task.
- Project-declared requirement and where it was found.
- Active command path and version.
- Direct-to-outer manager chain, install strategy, and update owner.
- Actions performed or planned.
- Verification command results.
- Any remaining approval needed before persistent machine changes.
