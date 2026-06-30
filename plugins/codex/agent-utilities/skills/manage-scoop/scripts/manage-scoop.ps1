param(
    [ValidateSet("check", "install", "update")]
    [string]$Action = "check",
    [string[]]$Apps = @(),
    [switch]$Apply
)

$ErrorActionPreference = "Stop"

function Require-Apply {
    param([string]$Operation)
    if (-not $Apply) {
        Write-Host "$Operation requested, but -Apply was not provided."
        Write-Host "No changes were made."
        exit 0
    }
}

function Test-Scoop {
    $command = Get-Command scoop -ErrorAction SilentlyContinue
    if ($null -eq $command) {
        Write-Host "Scoop: missing"
        return $false
    }
    Write-Host "Scoop: found at $($command.Source)"
    scoop --version
    return $true
}

switch ($Action) {
    "check" {
        if (Test-Scoop) {
            Write-Host ""
            Write-Host "Scoop status:"
            scoop status -l
            Write-Host ""
            Write-Host "Installed apps:"
            scoop list
        }
    }
    "install" {
        if (-not (Test-Scoop)) {
            Require-Apply "Scoop install"
            Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
            irm get.scoop.sh | iex
        }

        foreach ($app in $Apps) {
            if (-not $Apply) {
                Write-Host "Would run: scoop install $app"
            } else {
                scoop install $app
            }
        }
    }
    "update" {
        if (-not (Test-Scoop)) {
            throw "Scoop is required before update."
        }
        if ($Apps.Count -eq 0) {
            if (-not $Apply) {
                Write-Host "Would run: scoop update"
            } else {
                scoop update
            }
            return
        }
        foreach ($app in $Apps) {
            if (-not $Apply) {
                Write-Host "Would run: scoop update $app"
            } else {
                scoop update $app
            }
        }
    }
}
