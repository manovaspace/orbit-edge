#!/usr/bin/env bash
# Run every test-*.sh in this directory. CI calls this directly.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
shopt -s nullglob
tests=("$HERE"/test-*.sh)
shopt -u nullglob

[[ ${#tests[@]} -gt 0 ]] || { echo "no tests found in $HERE" >&2; exit 1; }

for test in "${tests[@]}"; do
  echo "==> $(basename "$test")"
  bash "$test"
done
