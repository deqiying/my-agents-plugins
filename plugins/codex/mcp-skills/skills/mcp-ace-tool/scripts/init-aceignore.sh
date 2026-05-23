#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <absolute-project-root>" >&2
  exit 64
fi

root=$1
if [[ ! -d "$root" ]]; then
  echo "Project root must be an existing directory: $root" >&2
  exit 66
fi

if command -v realpath >/dev/null 2>&1; then
  root=$(realpath "$root")
fi

aceignore="$root/.aceignore"
gitignore="$root/.gitignore"

if [[ -f "$aceignore" ]]; then
  echo ".aceignore already exists: $aceignore"
  exit 0
fi

if [[ -e "$aceignore" ]]; then
  echo ".aceignore exists but is not a file: $aceignore" >&2
  exit 73
fi

if [[ -f "$gitignore" ]]; then
  cp "$gitignore" "$aceignore"
  echo "Created .aceignore from .gitignore: $aceignore"
  exit 0
fi

cat > "$aceignore" <<'ACEIGNORE'
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
ACEIGNORE

echo "Created .aceignore from conservative template: $aceignore"
