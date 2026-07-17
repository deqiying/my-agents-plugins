# Scoop Workflow

Use this workflow only for focused Windows Scoop work. It covers Scoop detection, install planning, bucket and app inspection, app installation, scoped updates, and post-install command resolution.

Windows `mise` ownership is Scoop-first when Scoop installed it. Update that copy with Scoop rather than `mise self-update`.

## Workflow

1. Confirm Windows with `$IsWindows` and `$PSVersionTable`.
2. Run check mode:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/manage-scoop.ps1 -Action check
```

3. If Scoop is missing, prepare an install plan and obtain explicit approval before running an installer or changing execution policy.
4. Before installing an app, read `tool-registry.yaml` when the tool is registered and preserve its direct-to-outer manager chain. Use Scoop only when it is the direct owner.
5. Before updating, inspect `scoop status -l`, then update only the requested app or scope.
6. Verify Scoop, the app record, every resolved command path, and the target version.

## Useful Checks

```powershell
Get-Command scoop -All
scoop --version
scoop status -l
scoop list
Get-Command mise -All
scoop list mise
mise --version
```

## Script Actions

```powershell
powershell -ExecutionPolicy Bypass -File scripts/manage-scoop.ps1 -Action check
powershell -ExecutionPolicy Bypass -File scripts/manage-scoop.ps1 -Action install -Apps mise -Apply
powershell -ExecutionPolicy Bypass -File scripts/manage-scoop.ps1 -Action update -Apps mise -Apply
```

`-Apply` is required for install and update. Without it, the script prints the planned commands.

## Safety

- Never run `Set-ExecutionPolicy`, `irm get.scoop.sh | iex`, `scoop install`, or `scoop update` without explicit approval.
- Do not run `scoop update *` unless the user explicitly approved updating every app.
- Prefer app-scoped updates such as `scoop update mise`.
- Do not create a Scoop copy of a tool whose declared direct owner is npm, brew, mise, or another manager.
- Use `<SCOOP_ROOT>`, `<SCOOP_GLOBAL>`, and `<HOME>` instead of machine-local paths in persistent text.
