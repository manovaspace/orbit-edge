#!/usr/bin/env bash
# Validate compose.yaml with placeholders only; never read a real .env file.
set -euo pipefail

ROOT="$(realpath "$(dirname "${BASH_SOURCE[0]}")/../..")"
command -v docker >/dev/null 2>&1 || { echo "Missing test tool: docker" >&2; exit 127; }

dir="$(mktemp -d)"
trap 'rm -rf -- "$dir"' EXIT
env_file="$dir/env"
missing_file="$dir/env-without-secret"

cat >"$env_file" <<'EOF'
JWT_SECRET=ci-only-not-for-production-use-32b
EOF

cat >"$missing_file" <<'EOF'
DEPLOYMENT_ENVIRONMENT=production
EOF

compose() {
  env -i PATH="$PATH" HOME="$dir" COMPOSE_DISABLE_ENV_FILE=1 \
    docker compose --project-directory "$dir" --env-file "$1" -f "$ROOT/compose.yaml" config -q
}

compose "$env_file" ||
  { echo "compose.yaml must validate with placeholder values" >&2; exit 1; }

set +e
out="$(compose "$missing_file" 2>&1)"
rc=$?
set -e
[[ "$rc" -ne 0 ]] ||
  { echo "compose.yaml must reject a missing JWT_SECRET" >&2; exit 1; }
grep -Fq 'JWT_SECRET' <<<"$out" ||
  { echo "failure must name JWT_SECRET: $out" >&2; exit 1; }

echo "compose.yaml validates with placeholders and refuses to interpolate without JWT_SECRET"
