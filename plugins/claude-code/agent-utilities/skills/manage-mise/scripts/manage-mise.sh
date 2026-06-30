#!/usr/bin/env bash
set -euo pipefail

action="${1:-check}"
shift || true

apply="false"
global="false"
tools=""

while [ $# -gt 0 ]; do
  case "$1" in
    --apply)
      apply="true"
      shift
      ;;
    --global)
      global="true"
      shift
      ;;
    *)
      tools="$tools $1"
      shift
      ;;
  esac
done

require_mise() {
  if ! command -v mise >/dev/null 2>&1; then
    echo "mise is missing. Install or repair mise before managing tools." >&2
    exit 1
  fi
}

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
    require_mise
    mise --version
    echo
    echo "Current mise tools:"
    mise ls --current
    echo
    echo "Installed mise tools:"
    mise ls --installed
    ;;
  install)
    require_mise
    if [ -z "$tools" ]; then
      echo "Install requires at least one tool, for example node@latest." >&2
      exit 2
    fi
    for tool in $tools; do
      if [ "$global" = "true" ]; then
        run_or_plan mise use --global "$tool"
      else
        run_or_plan mise install "$tool"
      fi
    done
    ;;
  update)
    require_mise
    if [ -z "$tools" ]; then
      run_or_plan mise upgrade
    else
      for tool in $tools; do
        run_or_plan mise upgrade "$tool"
      done
    fi
    ;;
  *)
    echo "Unsupported action: $action" >&2
    exit 2
    ;;
esac
