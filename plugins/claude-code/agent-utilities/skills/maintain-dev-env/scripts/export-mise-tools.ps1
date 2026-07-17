param(
    [string]$OutputPath = ""
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command mise -ErrorAction SilentlyContinue)) {
    throw "mise is not available on PATH."
}

$raw = mise ls --current --json | ConvertFrom-Json
$items = @()

foreach ($property in $raw.PSObject.Properties) {
    $toolId = $property.Name
    foreach ($entry in $property.Value) {
        $sourceType = $null
        if ($entry.source -and $entry.source.type) {
            $sourceType = $entry.source.type
        }
        $items += [pscustomobject]@{
            id = $toolId
            version = $entry.version
            requested_version = $entry.requested_version
            installed = $entry.installed
            active = $entry.active
            install_path = "<MISE_DATA_DIR>/installs/<tool>/<version>"
            source = [pscustomobject]@{
                type = $sourceType
                path = "<GLOBAL_MISE_CONFIG>"
            }
        }
    }
}

$json = ($items | ConvertTo-Json -Depth 6).Replace("\u003c", "<").Replace("\u003e", ">")
if ($OutputPath) {
    Set-Content -Path $OutputPath -Value $json -Encoding utf8
} else {
    $json
}
