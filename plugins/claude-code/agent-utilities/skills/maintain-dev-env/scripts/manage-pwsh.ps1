param(
    [ValidateSet("check", "install", "update")]
    [string]$Action = "check",
    [switch]$Apply
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = "Stop"

$PackageId = "Microsoft.PowerShell"
$PackageSource = "winget"
$InstallerType = "wix"
$ExpectedRoot = Join-Path $env:ProgramFiles "PowerShell\7"
$NoApplicableInstallerExitCode = -1978335216
$UpdateNotApplicableExitCode = -1978335189

function Get-WingetCommand {
    $commands = @(Get-Command winget.exe -All -ErrorAction SilentlyContinue)
    if ($commands.Count -eq 0) {
        throw "winget.exe is required to maintain PowerShell 7."
    }
    return $commands[0]
}

function Invoke-WingetReadOnly {
    param(
        [System.Management.Automation.CommandInfo]$Command,
        [string[]]$Arguments
    )

    & $Command.Source @Arguments | Out-Host
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "winget $($Arguments -join ' ') failed with exit code $LASTEXITCODE."
        return $false
    }
    return $true
}

function Invoke-WingetApply {
    param(
        [System.Management.Automation.CommandInfo]$Command,
        [string[]]$Arguments,
        [int[]]$AcceptedExitCodes = @(0)
    )

    & $Command.Source @Arguments
    $exitCode = $LASTEXITCODE
    if ($exitCode -eq $NoApplicableInstallerExitCode) {
        throw "WinGet found no policy-compliant WiX installer. The existing MSI was retained; MSIX fallback remains disabled."
    }
    if ($AcceptedExitCodes -notcontains $exitCode) {
        throw "winget $($Arguments -join ' ') failed with exit code $exitCode."
    }
    return $exitCode
}

function Get-PowerShellMsiRecords {
    $uninstallPaths = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    return @(Get-ItemProperty -Path $uninstallPaths -ErrorAction SilentlyContinue |
        Where-Object {
            $displayNameProperty = $_.PSObject.Properties["DisplayName"]
            if ($null -eq $displayNameProperty -or $displayNameProperty.Value -notlike "PowerShell 7*") {
                return $false
            }

            $windowsInstallerProperty = $_.PSObject.Properties["WindowsInstaller"]
            $uninstallStringProperty = $_.PSObject.Properties["UninstallString"]
            $isWindowsInstaller = $null -ne $windowsInstallerProperty -and $windowsInstallerProperty.Value -eq 1
            $usesMsiExec = $null -ne $uninstallStringProperty -and $uninstallStringProperty.Value -match "(?i)msiexec\.exe"
            return $isWindowsInstaller -or $usesMsiExec
        })
}

function Get-PowerShellMsixPackages {
    if (-not (Get-Command Get-AppxPackage -ErrorAction SilentlyContinue)) {
        return @()
    }

    return @(Get-AppxPackage -Name "*PowerShell*" -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -like "Microsoft.PowerShell*" })
}

function Get-PowerShellCommands {
    $paths = @()
    foreach ($command in @(Get-Command pwsh.exe -All -ErrorAction SilentlyContinue)) {
        if ($command.CommandType -eq "Application" -and $command.Source) {
            $paths += $command.Source
        }
    }

    $expectedCommand = Join-Path $ExpectedRoot "pwsh.exe"
    if (Test-Path -LiteralPath $expectedCommand) {
        $paths += $expectedCommand
    }

    return @($paths | Select-Object -Unique)
}

function Test-PathWithin {
    param(
        [string]$Path,
        [string]$Root
    )

    $fullPath = [IO.Path]::GetFullPath($Path)
    $fullRoot = [IO.Path]::GetFullPath($Root).TrimEnd("\")
    return $fullPath.Equals($fullRoot, [StringComparison]::OrdinalIgnoreCase) -or
        $fullPath.StartsWith("$fullRoot\", [StringComparison]::OrdinalIgnoreCase)
}

function Get-PolicyEvidence {
    $issues = New-Object System.Collections.Generic.List[string]
    $wingetCommand = $null

    Write-Host "PowerShell 7 policy: winget/$PackageId, installer type $InstallerType (MSI), machine scope"
    try {
        $wingetCommand = Get-WingetCommand
        Write-Host "winget: $($wingetCommand.Source)"
        if (-not (Invoke-WingetReadOnly -Command $wingetCommand -Arguments @("--version"))) {
            [void]$issues.Add("winget resolved but could not execute.")
        }
        Write-Host ""
        Write-Host "WinGet package record:"
        if (-not (Invoke-WingetReadOnly -Command $wingetCommand -Arguments @("list", "--id", $PackageId, "--exact", "--source", $PackageSource))) {
            [void]$issues.Add("The exact WinGet package record could not be verified.")
        }
    } catch {
        [void]$issues.Add($_.Exception.Message)
        Write-Warning $_.Exception.Message
    }

    $msiRecords = @(Get-PowerShellMsiRecords)
    Write-Host ""
    Write-Host "MSI/WiX uninstall records:"
    if ($msiRecords.Count -eq 0) {
        Write-Host "MISSING"
        [void]$issues.Add("No PowerShell 7 MSI/WiX uninstall record was found.")
    } else {
        foreach ($record in $msiRecords) {
            Write-Host ("FOUND {0}: {1}" -f $record.DisplayName, $record.DisplayVersion)
        }
    }

    $msixPackages = @(Get-PowerShellMsixPackages)
    Write-Host ""
    Write-Host "PowerShell MSIX packages:"
    if ($msixPackages.Count -eq 0) {
        Write-Host "NONE"
    } else {
        foreach ($package in $msixPackages) {
            Write-Host ("UNSUPPORTED {0}: {1}" -f $package.Name, $package.PackageFullName)
        }
        [void]$issues.Add("A PowerShell MSIX package is installed for the current user.")
    }

    $pwshPaths = @(Get-PowerShellCommands)
    Write-Host ""
    Write-Host "Resolved pwsh.exe paths:"
    if ($pwshPaths.Count -eq 0) {
        Write-Host "MISSING"
        [void]$issues.Add("pwsh.exe was not found.")
    } else {
        foreach ($path in $pwshPaths) {
            Write-Host "FOUND $path"
            if (-not (Test-PathWithin -Path $path -Root $ExpectedRoot)) {
                [void]$issues.Add("PowerShell 7 resolves outside the MSI/WiX root: $path")
            }
        }

        $primaryPwsh = $pwshPaths[0]
        $version = & $primaryPwsh -NoLogo -NoProfile -Command '$PSVersionTable.PSVersion.ToString()'
        if ($LASTEXITCODE -ne 0) {
            [void]$issues.Add("pwsh.exe version check failed with exit code $LASTEXITCODE.")
        } else {
            Write-Host "PowerShell version: $version"
        }

        $resolvedPsHome = & $primaryPwsh -NoLogo -NoProfile -Command '$PSHOME'
        if ($LASTEXITCODE -ne 0) {
            [void]$issues.Add("pwsh.exe PSHOME check failed with exit code $LASTEXITCODE.")
        } else {
            Write-Host "PSHOME: $resolvedPsHome"
            if (-not (Test-PathWithin -Path $resolvedPsHome -Root $ExpectedRoot)) {
                [void]$issues.Add("PSHOME is outside the MSI/WiX root: $resolvedPsHome")
            }
        }
    }

    return [pscustomobject]@{
        Issues = @($issues)
        MsiRecords = $msiRecords
        MsixPackages = $msixPackages
        PowerShellPaths = $pwshPaths
        WingetCommand = $wingetCommand
    }
}

function Show-PolicyResult {
    param([pscustomobject]$Evidence)

    Write-Host ""
    if ($Evidence.Issues.Count -eq 0) {
        Write-Host "PowerShell 7 policy check: PASS"
        return $true
    }

    Write-Host "PowerShell 7 policy check: FAIL"
    foreach ($issue in $Evidence.Issues) {
        Write-Host "- $issue"
    }
    return $false
}

function Assert-ApplyPreconditions {
    param(
        [pscustomobject]$Evidence,
        [switch]$RequireMsi
    )

    if ($Evidence.MsixPackages.Count -gt 0) {
        throw "PowerShell MSIX is installed. Automatic migration is not supported."
    }
    foreach ($path in $Evidence.PowerShellPaths) {
        if (-not (Test-PathWithin -Path $path -Root $ExpectedRoot)) {
            throw "A PowerShell 7 copy outside the MSI/WiX root is active: $path"
        }
    }
    if ($RequireMsi -and $Evidence.MsiRecords.Count -eq 0) {
        throw "A verified PowerShell 7 MSI/WiX installation is required before update."
    }
    if ($null -eq $Evidence.WingetCommand) {
        throw "winget.exe is required to maintain PowerShell 7."
    }
}

if ($env:OS -ne "Windows_NT") {
    throw "manage-pwsh.ps1 supports Windows only."
}

$installArguments = @(
    "install", "--id", $PackageId, "--exact", "--source", $PackageSource,
    "--installer-type", $InstallerType, "--scope", "machine", "--no-upgrade",
    "--accept-package-agreements", "--accept-source-agreements"
)
$updateArguments = @(
    "upgrade", "--id", $PackageId, "--exact", "--source", $PackageSource,
    "--installer-type", $InstallerType, "--scope", "machine",
    "--accept-package-agreements", "--accept-source-agreements"
)

switch ($Action) {
    "check" {
        $evidence = Get-PolicyEvidence
        if (-not (Show-PolicyResult -Evidence $evidence)) {
            exit 1
        }
    }
    "install" {
        $wingetCommand = Get-WingetCommand
        if (-not $Apply) {
            Write-Host "Would run: winget $($installArguments -join ' ')"
            Write-Host "No changes were made."
            return
        }

        $evidence = Get-PolicyEvidence
        Assert-ApplyPreconditions -Evidence $evidence
        if ($evidence.MsiRecords.Count -gt 0) {
            Write-Host "PowerShell 7 MSI/WiX is already installed; install action made no changes."
        } else {
            $null = Invoke-WingetApply -Command $wingetCommand -Arguments $installArguments
        }
        $result = Get-PolicyEvidence
        if (-not (Show-PolicyResult -Evidence $result)) {
            exit 1
        }
    }
    "update" {
        $wingetCommand = Get-WingetCommand
        if (-not $Apply) {
            Write-Host "Would run: winget $($updateArguments -join ' ')"
            Write-Host "No changes were made."
            return
        }

        $evidence = Get-PolicyEvidence
        Assert-ApplyPreconditions -Evidence $evidence -RequireMsi
        $updateExitCode = Invoke-WingetApply -Command $wingetCommand -Arguments $updateArguments -AcceptedExitCodes @(0, $UpdateNotApplicableExitCode)
        if ($updateExitCode -eq $UpdateNotApplicableExitCode) {
            Write-Host "No applicable PowerShell 7 MSI/WiX update was found; the current version was retained."
        }
        $result = Get-PolicyEvidence
        if (-not (Show-PolicyResult -Evidence $result)) {
            exit 1
        }
    }
}
