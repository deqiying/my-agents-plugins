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

commands="brew mise node npm go rustc cargo python3 uv pnpm codex codesearch officecli onesearch doggo"
for name in $commands; do
  if command -v "$name" >/dev/null 2>&1; then
    paths="$(type -a -p "$name" 2>/dev/null || true)"
    if [ -z "$paths" ]; then
      paths="$(command -v "$name")"
    fi
    printf '%s\n' "$paths" | while IFS= read -r path; do
      printf 'FOUND %s: %s\n' "$name" "$path"
    done
  else
    printf 'MISSING %s\n' "$name"
  fi
done

if command -v mise >/dev/null 2>&1; then
  echo
  echo "mise current tools:"
  mise ls --current
fi

if command -v npm >/dev/null 2>&1; then
  echo
  echo "Active Node npm global prefix:"
  if ! npm prefix --global; then
    echo "npm prefix --global failed." >&2
  fi

  echo
  echo "Active Node npm global packages:"
  if ! npm list --global --depth=0; then
    echo "npm list --global --depth=0 reported an error." >&2
  fi
fi
