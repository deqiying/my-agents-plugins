#!/usr/bin/env bash
set -euo pipefail

action="${1:-check}"
shift || true

apply="false"
global="false"
allow_backend="false"
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
    --allow-backend)
      allow_backend="true"
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
    printf 'Running:'
    printf ' %s' "$@"
    echo
    "$@"
  else
    printf 'Would run:'
    printf ' %s' "$@"
    echo
  fi
}

assert_allowed_tool_spec() {
  case "$1" in
    npm:*)
      if [ "$allow_backend" != "true" ]; then
        echo "npm backend specs are disabled by default. Use npm directly, or pass --allow-backend only after an explicit migration and duplicate-installation check." >&2
        exit 2
      fi
      ;;
  esac
}

show_npm_global_state() {
  if ! command -v npm >/dev/null 2>&1; then
    return
  fi

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
    show_npm_global_state
    ;;
  install)
    require_mise
    if [ -z "$tools" ]; then
      echo "Install requires at least one tool, for example node@latest." >&2
      exit 2
    fi
    for tool in $tools; do
      assert_allowed_tool_spec "$tool"
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
        assert_allowed_tool_spec "$tool"
        run_or_plan mise upgrade "$tool"
      done
    fi
    ;;
  *)
    echo "Unsupported action: $action" >&2
    exit 2
    ;;
esac
