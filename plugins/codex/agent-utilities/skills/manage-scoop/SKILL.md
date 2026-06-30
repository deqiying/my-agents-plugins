---
name: manage-scoop
description: 'Use on Windows when Codex needs to check, install, update, or troubleshoot Scoop and Scoop-managed developer tools. Use as the supporting skill for Windows developer environment setup, especially when mise must be installed or updated through Scoop.'
---

# Manage Scoop

## Role

Use this skill only for Windows Scoop workflows. It covers Scoop detection, install planning, bucket/app inspection, app installation, app updates, and post-install PATH checks.

In this plugin, Windows `mise` ownership is Scoop-first: if `mise` is installed through Scoop, use Scoop to update `mise` instead of `mise self-update`.

## Default Workflow

1. Confirm the platform is Windows. If not Windows, route to `$manage-brew` for macOS or `$manage-mise` for mise-only Linux work.
2. Run check mode first:
   - `powershell -ExecutionPolicy Bypass -File scripts/manage-scoop.ps1 -Action check`
3. If Scoop is missing, read `references/scoop.md` and prepare an install plan. Do not run the remote installer until the user explicitly approves.
4. If the user asks to install apps, show the app list and manager ownership first. Avoid installing tools through Scoop if `$maintain-dev-tool-list` says they are owned by mise.
5. If the user asks to update, run status first, then update only the requested scope.
6. Verify `Get-Command scoop -All`, `scoop --version`, `scoop list`, and any installed app command.

## Script Actions

Use scripts from this skill directory:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/manage-scoop.ps1 -Action check
powershell -ExecutionPolicy Bypass -File scripts/manage-scoop.ps1 -Action install -Apps mise -Apply
powershell -ExecutionPolicy Bypass -File scripts/manage-scoop.ps1 -Action update -Apps mise -Apply
```

`-Apply` is required for install and update. Without `-Apply`, the script prints the planned commands and exits without changing the machine.

## Safety Rules

- Never run `Set-ExecutionPolicy`, `irm get.scoop.sh | iex`, `scoop install`, or `scoop update` without explicit user approval.
- Do not commit or write real Scoop roots. Use `<SCOOP_ROOT>` and `<SCOOP_GLOBAL>` in persistent text.
- Do not run `scoop update *` unless the user explicitly approved updating all apps.
- Prefer app-scoped updates such as `scoop update mise` when only one dependency is needed.
