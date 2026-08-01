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

function Show-ScopedEnvironmentVariable {
    param([string]$Name)

    foreach ($scope in @("Process", "User", "Machine")) {
        $value = [Environment]::GetEnvironmentVariable($Name, $scope)
        if ([string]::IsNullOrWhiteSpace($value)) {
            $value = "<unset>"
        }
        Write-Host ("{0} {1}: {2}" -f $Name, $scope, $value)
    }
}

Write-Host "Platform: Windows"
Write-Host "PowerShell host: $($PSVersionTable.PSVersion)"

$commands = @("winget", "pwsh", "scoop", "mise", "java", "javac", "mvn", "mvnd", "node", "npm", "go", "rustc", "cargo", "python", "uv", "pnpm", "codex", "officecli", "opencli", "onesearch", "ast-grep", "bat", "delta", "difft", "doggo", "fd", "fzf", "gh", "jq", "just", "rg", "sd", "sqlite3", "yq")
foreach ($name in $commands) {
    foreach ($result in @(Test-Command $name)) {
        if ($result.Found) {
            Write-Host ("FOUND {0}: {1}" -f $result.Name, $result.Source)
        } else {
            Write-Host ("MISSING {0}" -f $result.Name)
        }
    }
}

Write-Host ""
Write-Host "Java/Maven environment variables:"
foreach ($name in @("JAVA_HOME", "MAVEN_HOME", "MVND")) {
    Show-ScopedEnvironmentVariable $name
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
