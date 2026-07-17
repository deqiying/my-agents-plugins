param(
    [ValidateSet("check", "install", "update")]
    [string]$Action = "check",
    [string[]]$Tools = @(),
    [switch]$Global,
    [switch]$AllowBackend,
    [switch]$Apply
)

$ErrorActionPreference = "Stop"

function Expand-ToolSpecs {
    param([string[]]$Specs)

    foreach ($spec in $Specs) {
        foreach ($part in $spec.Split(",")) {
            $tool = $part.Trim()
            if ($tool) {
                $tool
            }
        }
    }
}

$Tools = @(Expand-ToolSpecs $Tools)

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

function Assert-AllowedToolSpec {
    param([string]$Tool)
    if ($Tool -match "^npm:" -and -not $AllowBackend) {
        throw "npm backend specs are disabled by default. Use npm as the direct manager, or pass -AllowBackend only after an explicit migration and duplicate-installation check."
    }
}

function Show-NpmGlobalState {
    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        return
    }

    Write-Host ""
    Write-Host "Active Node npm global prefix:"
    npm prefix --global
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "npm prefix --global failed with exit code $LASTEXITCODE."
    }

    Write-Host ""
    Write-Host "Active Node npm global packages:"
    npm list --global --depth=0
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "npm list --global --depth=0 reported exit code $LASTEXITCODE."
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
        Show-NpmGlobalState
    }
    "install" {
        Require-Mise
        if ($Tools.Count -eq 0) {
            throw "Install requires at least one tool, for example node@latest."
        }
        foreach ($tool in $Tools) {
            Assert-AllowedToolSpec $tool
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
            Assert-AllowedToolSpec $tool
            Invoke-Or-Plan @("mise", "upgrade", $tool)
        }
    }
}
