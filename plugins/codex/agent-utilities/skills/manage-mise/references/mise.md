# mise Notes

Use placeholders in persistent text:

- `<GLOBAL_MISE_CONFIG>` for the global config file.
- `<LOCAL_MISE_CONFIG>` for a project config under `<PROJECT_ROOT>`.
- `<MISE_DATA_DIR>` for the data directory containing installed tools.
- `<PROJECT_ROOT>` for the current repository or project being prepared.

Useful read-only checks:

```powershell
mise --version
mise doctor
mise ls --current --json
mise ls --installed
mise outdated --json
```

Common apply commands, only after explicit approval:

```powershell
mise use --global node@latest
mise use --global go@1.26.1
mise install
mise upgrade --dry-run
mise upgrade node
```

Use `mise use --global` for user-wide defaults and `mise use` from `<PROJECT_ROOT>` only when the project should carry a checked-in or local mise config.
