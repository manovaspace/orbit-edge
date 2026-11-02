#!/usr/bin/env bash
# pin-images.sh refuses to run without .env and writes digest pins from docker output.
set -euo pipefail

ROOT="$(realpath "$(dirname "${BASH_SOURCE[0]}")/../..")"

dir="$(mktemp -d)"
trap 'rm -rf -- "$dir"' EXIT

mkdir -p "$dir/scripts" "$dir/bin"
cp "$ROOT/scripts/pin-images.sh" "$dir/scripts/pin-images.sh"
# A placeholder only: the script checks that .env exists and the fake docker ignores its contents.
printf '# placeholder only\n' >"$dir/.env"

cat >"$dir/bin/docker" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" >>"${DOCKER_LOG:?}"
if [[ "$1" == "compose" && "$*" == *" images -q "* ]]; then
  printf '%s-image\n' "${!#}"
elif [[ "$1" == "image" && "$2" == "inspect" ]]; then
  printf 'sha256:%s\n' "${3%-image}"
fi
EOF
chmod +x "$dir/bin/docker"

fail() {
  echo "$*" >&2
  exit 1
}

: >"$dir/calls"
PATH="$dir/bin:$PATH" DOCKER_LOG="$dir/calls" bash "$dir/scripts/pin-images.sh" >/dev/null

grep -Fxq 'compose --env-file .env build' "$dir/calls" ||
  fail "pin-images.sh must build the compose stack: $(cat "$dir/calls")"

for service in auth notifications gateway; do
  grep -Fxq "ORBIT_${service^^}_IMAGE=sha256:${service}" "$dir/images.lock" ||
    fail "images.lock is missing the $service pin: $(cat "$dir/images.lock")"
done

for service in postgres redis mailpit; do
  grep -Fxq "  $service:" "$dir/compose.images.yaml" ||
    fail "compose.images.yaml is missing $service: $(cat "$dir/compose.images.yaml")"
  grep -Fxq "    image: sha256:${service}" "$dir/compose.images.yaml" ||
    fail "compose.images.yaml has the wrong $service pin: $(cat "$dir/compose.images.yaml")"
done

mv "$dir/.env" "$dir/env-removed"
set +e
out="$(PATH="$dir/bin:$PATH" DOCKER_LOG="$dir/calls" bash "$dir/scripts/pin-images.sh" 2>&1)"
rc=$?
set -e
[[ "$rc" -eq 1 ]] || fail "pin-images.sh without .env must exit 1 (got $rc)"
grep -Fq 'Copy .env.example to .env and set JWT_SECRET first.' <<<"$out" ||
  fail "pin-images.sh must explain the missing .env: $out"

echo "pin-images.sh writes image pins and refuses to run without .env"
