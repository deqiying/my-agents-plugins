[CmdletBinding()]
param(
  [Parameter(Mandatory = $true, Position = 0)]
  [Alias('Root')]
  [string]$ProjectRoot
)

$ErrorActionPreference = 'Stop'

$resolvedRoot = (Resolve-Path -LiteralPath $ProjectRoot).ProviderPath
$rootItem = Get-Item -LiteralPath $resolvedRoot
if (-not $rootItem.PSIsContainer) {
  throw "ProjectRoot must be a directory: $resolvedRoot"
}

$aceignore = Join-Path $resolvedRoot '.aceignore'
$gitignore = Join-Path $resolvedRoot '.gitignore'

if (Test-Path -LiteralPath $aceignore -PathType Leaf) {
  Write-Output ".aceignore already exists: $aceignore"
  exit 0
}

if (Test-Path -LiteralPath $aceignore) {
  throw ".aceignore exists but is not a file: $aceignore"
}

if (Test-Path -LiteralPath $gitignore -PathType Leaf) {
  Copy-Item -LiteralPath $gitignore -Destination $aceignore -ErrorAction Stop
  Write-Output "Created .aceignore from .gitignore: $aceignore"
  exit 0
}

$template = @'
# ace-tool-rs project-specific ignores
.ace-tool/
node_modules/
vendor/
.venv/
venv/
dist/
build/
target/
out/
bin/
obj/
.next/
.nuxt/
.cache/
coverage/
logs/
tmp/
temp/
**/Generated/**
*.gen.*
*.generated.*
*.min.js
*.min.css
*.map
*.log
*.tmp
*.png
*.jpg
*.jpeg
*.gif
*.ico
*.mp4
*.zip
*.tar
*.gz
*.rar
*.pdf
*.doc
*.docx
*.xls
*.xlsx
*.db
*.sqlite
*.sqlite3
'@

$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
[System.IO.File]::WriteAllText($aceignore, $template + [Environment]::NewLine, $utf8NoBom)
Write-Output "Created .aceignore from conservative template: $aceignore"
