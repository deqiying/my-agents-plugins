---
name: setup-dev-env
description: 'Use when the user explicitly asks to initialize, audit, check, prepare, install, update, or repair a local developer environment for Codex and agent development across Windows, macOS, or Linux. Use for user-requested machine setup involving Node, Go, Python, uv, pnpm, Codex CLI, mise, Scoop, Homebrew, or common developer tools; for environment issues discovered while doing another task, prefer maintain-dev-env first.'
---

# Setup Dev Env

## Role

Use this as the coordinator when the user intentionally asks for local developer environment setup or a full environment audit. It should inspect the machine, choose the right supporting skill, and report a concrete plan before changing tools, PATH, shell profile files, or package manager state.

For incidental environment blockers discovered while building, testing, generating, or debugging another project, use `$maintain-dev-env` first.

Do not put real machine-specific user directories into skill text, committed docs, examples, logs, or generated registry files. Use placeholders from `references/placeholders.md`, such as `<HOME>`, `<PROJECT_ROOT>`, `<GLOBAL_MISE_CONFIG>`, `<MISE_DATA_DIR>`, and `<SCOOP_ROOT>`.

## Supporting Skills

- Use `$manage-scoop` for Windows Scoop checks, install, update, and Scoop-managed apps. On Windows, treat Scoop as the default prerequisite path for installing or updating `mise`.
- Use `$manage-mise` for mise itself and mise-managed languages or tools such as Node, Go, Python, uv, pnpm, Codex CLI, `codesearch`, `officecli`, and `doggo`.
- Use `$manage-brew` for macOS Homebrew checks, install, update, and brew-managed developer tools. On macOS, prefer Homebrew for tools that are more native or stable through brew than through mise.
- Use `$maintain-dev-tool-list` before changing the shared tool set or when the user asks which tools should be checked, installed, pinned, or updated.

## Default Workflow

1. Identify the platform with shell-native facts:
   - Windows: `$PSVersionTable`, `$IsWindows`, `Get-Command`.
   - macOS/Linux: `uname -s`, `command -v`.
2. Load `references/placeholders.md` before writing any persistent text that might mention local paths.
3. Run a read-only check first:
   - Windows: `powershell -ExecutionPolicy Bypass -File scripts/check-dev-env.ps1 -Action check`
   - macOS/Linux: `bash scripts/check-dev-env.sh check`
4. Read the tool registry from `$maintain-dev-tool-list` when the task involves a tool set rather than a single named tool.
5. Build a platform-specific plan:
   - Windows: check Scoop, then check mise, then inspect mise tools.
   - macOS: check Homebrew and mise, then choose manager per tool.
   - Linux: check mise and shell prerequisites; use distro package managers only when the user explicitly asks or the project requires them.
6. Execute install/update only when the user explicitly asked for that action or confirmed the plan. If the user only asked to "check" or "analyze", stop at a report.
7. Verify with actual commands after any change: manager version, target tool version, PATH resolution, and relevant project command if known.

## Safety Rules

- Do not run remote installer commands, package manager updates, `mise upgrade`, `scoop update`, `brew upgrade`, shell profile edits, or PATH changes without explicit user approval.
- Prefer dry-run or check mode before applying changes.
- Keep manager ownership clear. Do not install the same tool through both Scoop and mise unless the user intentionally wants both.
- On Windows, if `mise` was installed through Scoop, update it through `$manage-scoop` instead of `mise self-update`.
- On macOS, prefer `$manage-brew` for Homebrew-owned tools and `$manage-mise` for language runtimes or tools already tracked by mise.
- Treat shell profile and PATH changes as persistent environment changes; show the exact target file using placeholders before editing.

## Reporting

Return a compact report with:

- Platform and detected shell.
- Package managers found or missing.
- Tool registry status: present, missing, outdated, or skipped.
- Actions performed, if any.
- Verification commands and results.
- Any remaining user decision, such as choosing between brew and mise for a tool.
