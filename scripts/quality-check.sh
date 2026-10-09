#!/usr/bin/env bash
# Validate interpolation with public CI values; preserve real .env and start no service.
set -euo pipefail
ROOT="$(realpath "$(dirname "${BASH_SOURCE[0]}")/..")"
for tool in docker shellcheck; do
  command -v "$tool" >/dev/null 2>&1 || { echo "Missing static-check tool: $tool" >&2; exit 127; }
done
docker compose version >/dev/null || { echo "Missing static-check tool: Docker Compose v2" >&2; exit 127; }
scratch="$(mktemp -d)"
trap 'rm -rf -- "$scratch"' EXIT
cp "$ROOT/.env.example" "$scratch/env"
env -i PATH="$PATH" HOME="$scratch" JWT_SECRET=ci-only-not-for-production-use-32b \
  docker compose --project-directory "$ROOT" --env-file "$scratch/env" -f "$ROOT/compose.yaml" config >/dev/null
shellcheck "$ROOT"/scripts/*.sh
echo "Static Compose/shell checks passed; deployment credentials and runtime remain unverified."
