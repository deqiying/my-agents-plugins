---
name: maintain-dev-env
description: Use as the single developer-environment skill when an agent needs to audit, set up, repair, update, or troubleshoot local toolchains on Windows, macOS, or Linux. Use for missing commands, PATH or shim issues, PowerShell 7 or pwsh maintained through WinGet as an MSI/WiX package, Scoop, mise, Homebrew, Java or JDK, Maven or mvnd, nested manager ownership, duplicate CLI copies, Node npm globals, shared tool registries, project/runtime mismatches, and tool installation or repair before building, testing, generating, or debugging.
---

# Maintain Dev Env

Use this as the only discoverable developer-environment skill. Handle broad diagnosis here, then load only the bundled reference needed for the current manager or registry operation.

## Reference Routing

1. Read [winget.md](./references/winget.md) for WinGet-owned PowerShell 7 maintenance on Windows. Preserve the MSI/WiX package policy and reject MSIX fallback.
2. Read [scoop.md](./references/scoop.md) for Windows Scoop work, including Scoop-owned `mise`.
3. Read [mise.md](./references/mise.md) for mise-managed runtimes and tools, project version mismatches, nested manager chains, or npm-global recovery after a Node change.
4. Read [brew.md](./references/brew.md) for macOS Homebrew and brew-owned tools.
5. Read [tool-registry.md](./references/tool-registry.md) together with [tool-registry.yaml](./references/tool-registry.yaml) when auditing or changing the shared desired tool set, manager ownership, version policy, or Node `postinstall` recovery list.
6. Read [placeholders.md](./references/placeholders.md) before writing persistent text that may contain local paths.

Read only the references required for the current step. These are supporting workflows, not separately discoverable skills.

## Default Workflow

1. Identify whether the user requested a machine-wide audit/setup or whether a project task exposed a focused environment blocker.
2. Identify the platform and shell with real commands.
3. Read project toolchain declarations before trusting global commands:
   - Go: `go.mod`, `toolchain`, `mise.toml`, `.tool-versions`.
   - Rust: `rust-toolchain.toml`, `Cargo.toml` `rust-version`, `mise.toml`, `.tool-versions`.
   - Java/Maven: `pom.xml` compiler or toolchain settings, `.mvn/jvm.config`, `.mvn/maven.config`, `.mvn/wrapper/maven-wrapper.properties`, `.java-version`, `mise.toml`, `.tool-versions`.
   - Node: `package.json` `engines` and `packageManager`, `.node-version`, `.nvmrc`, `mise.toml`, `.tool-versions`.
   - Python: `pyproject.toml` `requires-python`, `.python-version`, `uv.lock`, `mise.toml`, `.tool-versions`.
4. When the task just created or changed a project-level mise config, review its exact path and run `mise trust --show`. If `mise` reports that same reviewed config as untrusted, trust only it with `mise trust --yes <LOCAL_MISE_CONFIG>` before running the affected project command. This trust action is authorized within the task that created or changed the config; otherwise request approval.
5. Run read-only inspection first. For a broad audit, use:
   - Windows: `powershell -ExecutionPolicy Bypass -File scripts/check-dev-env.ps1 -Action check`
   - macOS/Linux: `bash scripts/check-dev-env.sh check`
6. Resolve every affected command and inspect its actual version. For Java/Maven, resolve `java`, `javac`, `mvn`, and `mvnd`, then verify `JAVA_HOME` and Maven's reported Java runtime after mise activation. For npm globals, use `npm prefix --global`, `npm list --global --depth=0`, and direct command resolution before mise-specific lookup.
7. Determine the direct-to-outer `manager_chain`, `install_strategy`, and `update_owner`. Use the registry as desired state, not proof of installation.
8. Load the relevant reference and choose the smallest corrective action. Prefer project-aware or temporary execution before changing shared/global state.
9. After an authorized change, verify manager state, all resolved command paths, the target version, and the original blocked command.

## Ownership And Version Rules

- Prefer the native package manager as direct lifecycle owner. Do not infer ownership from a shim or an outer runtime manager.
- On Windows, maintain stable PowerShell 7 through WinGet package `Microsoft.PowerShell` with installer type `wix`. Do not remove the installer-type constraint or replace it with the default MSIX package.
- Preserve nested chains such as `[npm, mise]`; do not flatten them to `[mise]`.
- Use `latest` for shared/global runtimes and tools unless the user explicitly requests a global pin.
- Follow project-declared versions inside a project. Do not change a repository requirement merely to match the active global tool.
- Treat multiple mutable global copies as unresolved until one update owner is selected. Classify lower-precedence product-bundled fallbacks separately.

## Safety Rules

- Do not run remote installers, package-manager updates, profile/PATH edits, prune operations, or other persistent machine changes without explicit user approval.
- Do not install the same tool through multiple managers unless the user intentionally chooses that layout.
- Do not use a mise ecosystem backend as the default repair when a native package manager is the declared direct owner.
- Do not use `mise trust --all`. The automatic trust exception applies only to the reviewed project config that the current task created or changed; never trust a parent, sibling, or unrelated config implicitly.
- Keep persistent text sanitized with the placeholders in `references/placeholders.md`.
- Keep all provided scripts read-only or dry-run by default; require `-Apply` or `--apply` for supported mutations.

## Reporting

Report the issue, project requirement source, active command path and version, manager chain, action performed or planned, verification result, and any remaining approval or uncertainty.
