#!/usr/bin/env bash
set -euo pipefail

action="${1:-check}"
if [ "$action" != "check" ]; then
  echo "Unsupported action: $action" >&2
  exit 2
fi

platform="$(uname -s)"
echo "Platform: $platform"
echo "Shell: ${SHELL:-unknown}"

commands="brew mise node go python3 uv pnpm codex codesearch officecli onesearch doggo"
for name in $commands; do
  if command -v "$name" >/dev/null 2>&1; then
    printf 'FOUND %s: %s\n' "$name" "$(command -v "$name")"
  else
    printf 'MISSING %s\n' "$name"
  fi
done

if command -v mise >/dev/null 2>&1; then
  echo
  echo "mise current tools:"
  mise ls --current
fi
