---
name: maintain-dev-tool-list
description: 'Use when Codex needs to maintain the shared developer tool registry for agent work, including tools, runtimes, package manager ownership, version policies, check commands, and sanitized exports from mise, Scoop, or Homebrew.'
---

# Maintain Dev Tool List

## Role

Use this skill to maintain the tool registry that `$setup-dev-env`, `$manage-scoop`, `$manage-mise`, and `$manage-brew` use when checking or preparing developer machines.

The first registry seed is based on the active tools from `mise ls --current`, with all real local paths replaced by placeholders. Future updates may add Scoop or Homebrew tools, but manager ownership must be explicit.

## Registry Files

- `references/tool-registry.yaml` is the curated registry.
- `scripts/export-mise-tools.ps1` and `scripts/export-mise-tools.sh` export sanitized current mise tools for review.

Do not commit raw `mise ls --current --json` output, because it includes local install paths and config paths. Always sanitize paths to placeholders first.

## Maintenance Workflow

1. Read `references/tool-registry.yaml`.
2. Inspect the current machine only when needed:
   - Windows: `powershell -ExecutionPolicy Bypass -File scripts/export-mise-tools.ps1`
   - macOS/Linux: `bash scripts/export-mise-tools.sh`
3. Compare current tools to the registry by `id`, `manager`, `version_policy`, and `command`.
4. Add or update entries only when they are useful across agent development tasks.
5. Preserve manager ownership:
   - `scoop` for Windows package manager and Windows-native CLI apps.
   - `mise` for language runtimes and cross-platform agent tools.
   - `brew` for macOS package manager and macOS-native CLI apps.
6. Before removing a tool, check whether any skill or plugin references its command.

## Entry Rules

Each registry entry should include:

- `id`: package or mise tool id, such as `node` or `github:flupkede/codesearch`.
- `command`: command expected on PATH.
- `manager`: `scoop`, `mise`, or `brew`.
- `category`: `runtime`, `agent-tool`, `package-manager`, or `utility`.
- `version_policy`: `latest`, exact version, or explicit range.
- `check`: short command list for verification.
- `notes`: only durable notes; no machine-local paths.

## Safety Rules

- Do not add real values like user names, home directories, install paths, or local config paths.
- Do not change a tool's manager just because another manager can install it.
- Do not use the registry as proof that a tool is installed. It is desired state; verify the actual machine with manager-specific commands.
