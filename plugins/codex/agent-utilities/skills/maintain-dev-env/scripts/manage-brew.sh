#!/usr/bin/env bash
set -euo pipefail

action="${1:-check}"
shift || true

apply="false"
items=""

while [ $# -gt 0 ]; do
  case "$1" in
    --apply)
      apply="true"
      shift
      ;;
    *)
      items="$items $1"
      shift
      ;;
  esac
done

run_or_plan() {
  if [ "$apply" = "true" ]; then
    printf 'Running: %q ' "$@"
    echo
    "$@"
  else
    printf 'Would run: %q ' "$@"
    echo
  fi
}

case "$action" in
  check)
    if [ "$(uname -s)" != "Darwin" ]; then
      echo "Homebrew workflow is macOS-first; current platform: $(uname -s)"
    fi
    if ! command -v brew >/dev/null 2>&1; then
      echo "brew is missing"
      exit 0
    fi
    brew --version
    brew --prefix
    echo
    echo "Installed formulas:"
    brew list --versions
    echo
    echo "Outdated formulas:"
    brew outdated || true
    ;;
  install)
    if ! command -v brew >/dev/null 2>&1; then
      echo "brew is missing. Install Homebrew before installing formulas." >&2
      exit 1
    fi
    if [ -z "$items" ]; then
      echo "Install requires at least one formula." >&2
      exit 2
    fi
    run_or_plan brew install $items
    ;;
  update)
    if ! command -v brew >/dev/null 2>&1; then
      echo "brew is missing." >&2
      exit 1
    fi
    run_or_plan brew update
    if [ -z "$items" ]; then
      run_or_plan brew upgrade
    else
      run_or_plan brew upgrade $items
    fi
    ;;
  *)
    echo "Unsupported action: $action" >&2
    exit 2
    ;;
esac
