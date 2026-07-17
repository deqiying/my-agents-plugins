# Homebrew Workflow

Use this workflow for focused macOS Homebrew maintenance: brew detection, install planning, formula or cask inspection, scoped installs and updates, and verification. On Linux, use it only when the user already uses Linuxbrew or explicitly requests it.

## Workflow

1. Confirm the platform with `uname -s`.
2. Run check mode:

```bash
bash scripts/manage-brew.sh check
```

3. If Homebrew is missing, verify the current official install source and obtain explicit approval before running its installer.
4. Before installing a tool, read `tool-registry.yaml` when the tool is registered and preserve its manager chain. Use brew only when it is the direct owner.
5. Inspect `brew outdated --json=v2` and `brew list --versions` before updating.
6. Apply only the approved formula, cask, or scope.
7. Verify brew, the installed package, every resolved command path, and the target version.

## Useful Checks

```bash
uname -s
command -v brew
brew --version
brew --prefix
brew list --versions
brew outdated --json=v2
```

## Script Actions

```bash
bash scripts/manage-brew.sh check
bash scripts/manage-brew.sh install --apply jq ripgrep
bash scripts/manage-brew.sh update --apply jq
```

`--apply` is required for install and update. Without it, the script prints the planned commands.

## Safety

- Never run Homebrew's remote install script without explicit approval.
- Do not use unscoped `brew upgrade` unless the user approved updating all formulas.
- Do not migrate a tool between brew, mise, or a native ecosystem manager without explaining the tradeoff and obtaining approval.
- Do not create a brew copy of a tool whose declared direct owner is another manager.
- Use `<BREW_PREFIX>` and `<HOME>` instead of machine-local paths in persistent text.
