#!/usr/bin/env bash
set -eu

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"

if command -v python3 >/dev/null 2>&1; then
  python_bin="python3"
elif command -v python >/dev/null 2>&1; then
  python_bin="python"
else
  echo "Python 3 was not found. Resolve the local agent toolchain before running this script." >&2
  exit 2
fi

exec "$python_bin" "$script_dir/memory_tools.py" new-note "$@"
