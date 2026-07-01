---
name: maintain-dev-env
description: 'Use as the broad main guidance when Codex encounters or anticipates local developer environment work during any task, not only when the user asks for setup. Use when commands, runtimes, package managers, PATH, shims, or tool versions may block work; when project-declared versions from go.mod, toolchain, mise.toml, .tool-versions, package.json engines/packageManager, .node-version, .nvmrc, pyproject.toml, or uv files differ from active Go, Node, Python, uv, pnpm, Codex CLI, mise, Scoop, Homebrew, or other tools; or when Codex needs to check, install, update, pin, repair, or temporarily run the required local toolchain before building, testing, generating, or debugging.'
---

# Maintain Dev Env

## Role

Use this as the broad coordinator for local developer environment maintenance discovered while doing other work. Trigger it when the task is blocked or may be misled by a missing command, wrong runtime version, stale shim, package-manager ownership issue, PATH problem, or mismatch between a project-declared version and the active environment.

For user-requested machine setup, full environment audits, or "prepare this machine" requests, route to `$setup-dev-env`. For the actual package manager or version manager work, route to `$manage-scoop`, `$manage-mise`, `$manage-brew`, or `$maintain-dev-tool-list`.

## Default Workflow

1. Identify whether the environment is relevant to the current task:
   - A command is missing or resolves to an unexpected path.
   - A build, test, generator, or CLI failed because a tool is absent, too old, too new, or from the wrong manager.
   - The project declares a tool version that differs from the active command version.
2. Read project version evidence before trusting global tools:
   - Go: `go.mod` `go` and `toolchain` directives, plus repository `mise.toml` or `.tool-versions`.
   - Node: `package.json` `engines` and `packageManager`, `.node-version`, `.nvmrc`, `mise.toml`, `.tool-versions`.
   - Python: `pyproject.toml` `requires-python`, `.python-version`, `uv.lock`, `mise.toml`, `.tool-versions`.
   - Other tools: repository docs, lockfiles, CI configs, and checked-in tool manager files.
3. Inspect the active environment with real commands:
   - Windows: `Get-Command <tool> -All`, `<tool> --version`, `mise ls --current --json` when available.
   - macOS/Linux: `command -v -a <tool>`, `<tool> --version`, `mise ls --current --json` when available.
4. Compare required and active versions. Report the exact source of the requirement and the active command path or version.
5. Choose the smallest corrective path:
   - If `mise` should manage the runtime or tool, use `$manage-mise`.
   - On Windows, if `mise` is missing or Scoop owns it, use `$manage-scoop`.
   - On macOS, if Homebrew owns the tool or is the better native manager, use `$manage-brew`.
   - If the shared desired tool set is wrong or missing an entry, use `$maintain-dev-tool-list`.
6. Prefer task-local or project-aware execution before changing global state:
   - If the project already has `mise.toml` or `.tool-versions`, install the required version and let the project config select it.
   - If no project config exists, prefer an install-only or temporary execution path such as `mise install <tool>@<version>` followed by `mise exec <tool>@<version> -- <command>`.
   - Do not write `mise.toml`, `.tool-versions`, shell profile files, or PATH changes unless the target file and intent are clear.
7. After any change, verify the manager state, command resolution, target tool version, and the original failed or blocked project command.

## Version Mismatch Pattern

When the active tool and project requirement differ, treat the project requirement as the default target for that project. For example, if `go version` reports `1.26.1` but `go.mod` or `toolchain` requires `1.26.4`, plan a precise install or activation such as `mise install go@1.26.4`, then verify with `mise exec go@1.26.4 -- go version` before rerunning the original Go command.

Do not "fix" the project by downgrading its declared version to match the global machine. Only propose changing project requirements when the user asked for a compatibility decision or the repository evidence clearly shows the declaration is wrong.

## Safety Rules

- Run read-only checks first whenever possible.
- Do not run remote installer commands, package-manager updates, `mise upgrade`, `scoop update`, `brew upgrade`, shell profile edits, PATH changes, or prune operations without explicit user approval.
- Do not install the same tool through multiple managers unless the user intentionally wants that layout.
- Keep persistent text sanitized. Replace local user directories with placeholders before writing tracked docs, logs, examples, or registry files.
- Treat registry entries as desired state, not proof that a tool is installed.

## Reporting

Return a compact maintenance report with:

- The environment issue and why it matters to the current task.
- Project-declared requirement and where it was found.
- Active command path and version.
- Manager ownership decision.
- Actions performed or planned.
- Verification command results.
- Any remaining approval needed before persistent machine changes.
