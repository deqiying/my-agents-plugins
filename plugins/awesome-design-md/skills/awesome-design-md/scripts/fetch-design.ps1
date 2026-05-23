param(
    [Parameter(Mandatory = $true)]
    [string]$Slug,

    [string]$Destination = (Get-Location).Path,

    [switch]$Force
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command npx -ErrorAction SilentlyContinue)) {
    throw "npx is required to fetch DESIGN.md files. Install Node.js and npm first."
}

$destinationPath = [System.IO.Path]::GetFullPath($Destination)

if (-not (Test-Path -LiteralPath $destinationPath)) {
    New-Item -ItemType Directory -Path $destinationPath -Force | Out-Null
}

$designPath = Join-Path $destinationPath "DESIGN.md"

if ((Test-Path -LiteralPath $designPath) -and -not $Force) {
    throw "DESIGN.md already exists at $designPath. Use -Force to replace it."
}

Push-Location $destinationPath
try {
    if ((Test-Path -LiteralPath $designPath) -and $Force) {
        Remove-Item -LiteralPath $designPath -Force
    }

    & npx -y getdesign@latest add $Slug

    if (-not (Test-Path -LiteralPath $designPath)) {
        throw "getdesign finished without creating DESIGN.md for slug '$Slug'."
    }

    Write-Output "Fetched DESIGN.md for '$Slug' into '$designPath'."
}
finally {
    Pop-Location
}
