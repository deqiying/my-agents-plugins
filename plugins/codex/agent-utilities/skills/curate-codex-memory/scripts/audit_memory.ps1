param(
    [string]$MemoryPath,
    [ValidateSet("Json", "Markdown")]
    [string]$Format = "Json",
    [int]$LongLineChars = 600,
    [int]$StaleAfterDays = 30,
    [int]$MaxGroupLines = 400
)

$ErrorActionPreference = "Stop"

$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) {
    $python = Get-Command python3 -ErrorAction SilentlyContinue
}
if (-not $python) {
    throw "Python 3 was not found. Resolve the local agent toolchain before running this script."
}

$arguments = @(
    (Join-Path $PSScriptRoot "memory_tools.py")
    "audit"
    "--format", $Format.ToLowerInvariant()
    "--long-line-chars", $LongLineChars
    "--stale-after-days", $StaleAfterDays
    "--max-group-lines", $MaxGroupLines
)
if ($MemoryPath) {
    $arguments += @("--memory-path", $MemoryPath)
}

& $python.Source @arguments
exit $LASTEXITCODE
