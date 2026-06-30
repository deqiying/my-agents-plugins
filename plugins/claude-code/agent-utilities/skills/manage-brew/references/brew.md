# Homebrew Notes

Use placeholders in persistent text:

- `<BREW_PREFIX>` for the Homebrew prefix.
- `<HOME>` for the user's home directory.

Common read-only checks:

```bash
uname -s
command -v brew
brew --version
brew --prefix
brew list --versions
brew outdated --json=v2
```

Common apply commands, only after explicit user approval:

```bash
brew update
brew install jq
brew upgrade jq
brew upgrade
```

For a fresh Homebrew install, verify the current official command before executing it, then ask the user for approval. Do not paste machine-local prefixes into docs or reports intended for commit.
