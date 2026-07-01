---
name: manage-brew
description: 'Use on macOS when an agent needs to check, install, update, or troubleshoot Homebrew and brew-managed developer tools. Use as the supporting skill for macOS developer environment setup when a tool is better maintained through brew than through mise.'
---

# Manage Brew

## Role

Use this skill for macOS Homebrew environment maintenance. It covers brew detection, install planning, formula/cask inspection, app installation, updates, and verification.

This skill is macOS-first. Do not use it for Windows. On Linux, use Homebrew only if the user already uses Linuxbrew or explicitly asks for it.

## Default Workflow

1. Confirm platform with `uname -s`.
2. Run check mode first:
   - `bash scripts/manage-brew.sh check`
3. If Homebrew is missing, read `references/brew.md`, verify the current official install source if needed, and ask before running an installer.
4. If a tool can be managed by both brew and mise, consult `$maintain-dev-tool-list` and choose one owner before installing.
5. For updates, inspect first:
   - `brew outdated --json=v2`
   - `brew list --versions`
6. Apply installs or upgrades only after explicit user approval.
7. Verify with `brew --version`, `brew list --versions <formula>`, and the target command's version output.

## Script Actions

```bash
bash scripts/manage-brew.sh check
bash scripts/manage-brew.sh install --apply jq ripgrep
bash scripts/manage-brew.sh update --apply jq
```

`--apply` is required for install and update. Without it, the script prints the planned commands.

## Safety Rules

- Never run Homebrew's remote install script without explicit approval.
- Do not use `brew upgrade` for all formulas unless the user approved broad updates.
- Do not write real brew prefixes into committed docs. Use `<BREW_PREFIX>`.
- Do not migrate a tool from mise to brew or brew to mise without explaining the tradeoff and getting user approval.
