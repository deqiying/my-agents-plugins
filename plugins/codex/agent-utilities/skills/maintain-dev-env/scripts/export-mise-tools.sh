#!/usr/bin/env bash
set -euo pipefail

if ! command -v mise >/dev/null 2>&1; then
  echo "mise is not available on PATH." >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required to sanitize mise JSON without leaking local paths." >&2
  exit 1
fi

mise ls --current --json |
  jq 'to_entries
    | map(
        .key as $tool
        | .value[]
        | {
            id: $tool,
            version: .version,
            requested_version: .requested_version,
            installed: .installed,
            active: .active,
            install_path: "<MISE_DATA_DIR>/installs/<tool>/<version>",
            source: {
              type: .source.type,
              path: "<GLOBAL_MISE_CONFIG>"
            }
          }
      )'
