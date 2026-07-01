param(
    [ValidateSet("check")]
    [string]$Action = "check"
)

$ErrorActionPreference = "Stop"

function Test-Command {
    param([string]$Name)
    $command = Get-Command $Name -ErrorAction SilentlyContinue
    if ($null -eq $command) {
        return [pscustomobject]@{
            Name = $Name
            Found = $false
            Source = $null
        }
    }
    return [pscustomobject]@{
        Name = $Name
        Found = $true
        Source = $command.Source
    }
}

Write-Host "Platform: Windows"
Write-Host "PowerShell: $($PSVersionTable.PSVersion)"

$commands = @("scoop", "mise", "node", "go", "python", "uv", "pnpm", "codex", "codesearch", "officecli", "onesearch", "doggo")
foreach ($name in $commands) {
    $result = Test-Command $name
    if ($result.Found) {
        Write-Host ("FOUND {0}: {1}" -f $result.Name, $result.Source)
    } else {
        Write-Host ("MISSING {0}" -f $result.Name)
    }
}

if (Get-Command mise -ErrorAction SilentlyContinue) {
    Write-Host ""
    Write-Host "mise current tools:"
    mise ls --current
}
