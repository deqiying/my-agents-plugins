# WinGet PowerShell 7 Workflow

Use this workflow only for stable PowerShell 7 maintenance on Windows. The declared lifecycle owner is WinGet package `Microsoft.PowerShell`; the required installer type is `wix` (MSI) with machine scope. MSIX, Microsoft Store, preview, Scoop, mise, ZIP, and .NET global-tool copies are outside this policy.

## Policy

- Always include `--installer-type wix`. WinGet selects MSIX by default for PowerShell 7.6.0 and later when the installer type is omitted.
- Use `--id Microsoft.PowerShell --exact --source winget` to avoid ambiguous packages or sources.
- Use `--scope machine` for install and upgrade.
- If the requested release has no WiX installer, retain the current compliant MSI version and report that no policy-compliant update is available. Never fall back to MSIX.
- Do not automatically uninstall or migrate an existing MSIX or another manager's copy. Report the conflict and obtain explicit approval for a separate migration task.

## Workflow

1. Confirm Windows and read the `powershell` entry in `tool-registry.yaml`.
2. Run the read-only policy check from Windows PowerShell 5.1 or another process that is not the PowerShell 7 installation being maintained:

```powershell
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File scripts/manage-pwsh.ps1 -Action check
```

3. Inspect all of the following evidence before changing state:
   - `winget` command resolution and version.
   - The exact `Microsoft.PowerShell` WinGet record.
   - Every resolved `pwsh.exe` path, `$PSHOME`, and the running version.
   - The machine uninstall record with `WindowsInstaller = 1` or an `MsiExec.exe` uninstall command.
   - Any current-user PowerShell MSIX package or resolved path under `WindowsApps`.
4. For an approved install or scoped update, run one action with `-Apply`:

```powershell
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File scripts/manage-pwsh.ps1 -Action install -Apply
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File scripts/manage-pwsh.ps1 -Action update -Apply
```

5. Re-run check mode from a new shell. Verify the WinGet record, MSI uninstall evidence, resolved `pwsh.exe`, `$PSHOME`, and version. Confirm that no MSIX or second mutable copy was introduced.

Without `-Apply`, install and update print the exact planned WinGet command and make no changes.

## Failure Handling

- If WinGet cannot execute, distinguish a missing command from an App Installer alias, sandbox, PATH, or source failure before changing installation state.
- Treat WinGet `APPINSTALLER_CLI_ERROR_UPDATE_NOT_APPLICABLE` as a successful no-op and verify the existing MSI. Treat `APPINSTALLER_CLI_ERROR_NO_APPLICABLE_INSTALLER` as a policy conflict, because no matching WiX installer is available.
- If an MSI operation reports files in use, close PowerShell 7 terminals and dependent processes, then retry from `powershell.exe` or `cmd.exe`. Do not terminate processes automatically.
- If the latest release lacks a WiX installer, report the version-policy conflict. Do not remove `--installer-type wix`, use `Microsoft.PowerShell.Preview`, or install from `msstore`.
