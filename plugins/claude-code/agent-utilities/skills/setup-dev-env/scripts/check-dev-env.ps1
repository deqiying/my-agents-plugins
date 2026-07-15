param(
    [ValidateSet("check")]
    [string]$Action = "check"
)

$ErrorActionPreference = "Stop"

function Test-Command {
    param([string]$Name)
    $commands = @(Get-Command $Name -All -ErrorAction SilentlyContinue)
    if ($commands.Count -eq 0) {
        return [pscustomobject]@{
            Name = $Name
            Found = $false
            Source = $null
        }
    }

    foreach ($command in $commands) {
        $source = if ($command.Path) { $command.Path } else { $command.Source }
        [pscustomobject]@{
            Name = $Name
            Found = $true
            Source = $source
        }
    }
}

Write-Host "Platform: Windows"
Write-Host "PowerShell: $($PSVersionTable.PSVersion)"

$commands = @("scoop", "mise", "node", "npm", "go", "rustc", "cargo", "python", "uv", "pnpm", "codex", "codesearch", "officecli", "opencli", "onesearch", "doggo")
foreach ($name in $commands) {
    foreach ($result in @(Test-Command $name)) {
        if ($result.Found) {
            Write-Host ("FOUND {0}: {1}" -f $result.Name, $result.Source)
        } else {
            Write-Host ("MISSING {0}" -f $result.Name)
        }
    }
}

if (Get-Command mise -ErrorAction SilentlyContinue) {
    Write-Host ""
    Write-Host "mise current tools:"
    mise ls --current
}

if (Get-Command npm -ErrorAction SilentlyContinue) {
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
