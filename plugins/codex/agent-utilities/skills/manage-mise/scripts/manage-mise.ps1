param(
    [ValidateSet("check", "install", "update")]
    [string]$Action = "check",
    [string[]]$Tools = @(),
    [switch]$Global,
    [switch]$Apply
)

$ErrorActionPreference = "Stop"

function Require-Mise {
    if (-not (Get-Command mise -ErrorAction SilentlyContinue)) {
        throw "mise is missing. On Windows, use manage-scoop to install mise first."
    }
}

function Invoke-Or-Plan {
    param([string[]]$Command)
    $display = $Command -join " "
    if ($Apply) {
        Write-Host "Running: $display"
        & $Command[0] $Command[1..($Command.Count - 1)]
    } else {
        Write-Host "Would run: $display"
    }
}

switch ($Action) {
    "check" {
        Require-Mise
        mise --version
        Write-Host ""
        Write-Host "Current mise tools:"
        mise ls --current
        Write-Host ""
        Write-Host "Installed mise tools:"
        mise ls --installed
    }
    "install" {
        Require-Mise
        if ($Tools.Count -eq 0) {
            throw "Install requires at least one tool, for example node@latest."
        }
        foreach ($tool in $Tools) {
            if ($Global) {
                Invoke-Or-Plan @("mise", "use", "--global", $tool)
            } else {
                Invoke-Or-Plan @("mise", "install", $tool)
            }
        }
    }
    "update" {
        Require-Mise
        if ($Tools.Count -eq 0) {
            Invoke-Or-Plan @("mise", "upgrade")
            return
        }
        foreach ($tool in $Tools) {
            Invoke-Or-Plan @("mise", "upgrade", $tool)
        }
    }
}
