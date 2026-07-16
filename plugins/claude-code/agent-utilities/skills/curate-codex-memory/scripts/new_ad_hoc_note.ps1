param(
    [Parameter(Mandatory)]
    [ValidateSet("Add", "Rewrite", "Forget", "Supersede")]
    [string]$Action,
    [Parameter(Mandatory)]
    [string]$Subject,
    [Parameter(Mandatory)]
    [string]$Details,
    [string[]]$Evidence = @(),
    [string]$MemoryRoot,
    [string]$Slug,
    [switch]$Apply
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
    "new-note"
    "--action", $Action.ToLowerInvariant()
    "--subject", $Subject
    "--details", $Details
)
foreach ($item in $Evidence) {
    $arguments += @("--evidence", $item)
}
if ($MemoryRoot) {
    $arguments += @("--memory-root", $MemoryRoot)
}
if ($Slug) {
    $arguments += @("--slug", $Slug)
}
if ($Apply) {
    $arguments += "--apply"
}

& $python.Source @arguments
exit $LASTEXITCODE
