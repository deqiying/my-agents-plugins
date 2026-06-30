# Scoop Notes

Scoop is the Windows package manager entrypoint for this plugin.

Use placeholders in persistent text:

- `<SCOOP_ROOT>` for the user-level Scoop root.
- `<SCOOP_GLOBAL>` for the global Scoop root.
- `<HOME>` for the user's home directory.

Common read-only checks:

```powershell
Get-Command scoop -All
scoop --version
scoop status -l
scoop list
```

Common apply commands, only after explicit user approval:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
irm get.scoop.sh | iex
scoop install mise
scoop update
scoop update mise
```

When checking `mise` on Windows, prefer:

```powershell
Get-Command mise -All
scoop list mise
mise --version
```
