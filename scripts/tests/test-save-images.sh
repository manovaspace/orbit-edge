#!/usr/bin/env bash
# save-images.sh refuses to run without images or .env and saves each image once.
set -euo pipefail

ROOT="$(realpath "$(dirname "${BASH_SOURCE[0]}")/../..")"

dir="$(mktemp -d)"
trap 'rm -rf -- "$dir"' EXIT

mkdir -p "$dir/scripts" "$dir/bin"
cp "$ROOT/scripts/save-images.sh" "$dir/scripts/save-images.sh"
# A placeholder only: the script checks that .env exists and the fake docker ignores its contents.
printf '# placeholder only\n' >"$dir/.env"

cat >"$dir/bin/docker" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if [[ "$1" == "compose" && "$*" == *" images -q"* ]]; then
  if [[ "${DOCKER_IMAGES:-}" == empty ]]; then
    exit 0
  fi
  printf 'img-b\nimg-a\nimg-a\n'
elif [[ "$1" == "save" ]]; then
  printf '%s\n' "$*" >>"${DOCKER_LOG:?}"
fi
EOF
chmod +x "$dir/bin/docker"

fail() {
  echo "$*" >&2
  exit 1
}

: >"$dir/calls"
PATH="$dir/bin:$PATH" DOCKER_LOG="$dir/calls" bash "$dir/scripts/save-images.sh" "$dir/images.tar" >/dev/null
grep -Fxq "save -o $dir/images.tar img-a img-b" "$dir/calls" ||
  fail "save-images.sh must save each image once: $(cat "$dir/calls")"

set +e
out="$(PATH="$dir/bin:$PATH" DOCKER_LOG="$dir/calls" DOCKER_IMAGES=empty bash "$dir/scripts/save-images.sh" "$dir/empty.tar" 2>&1)"
rc=$?
set -e
[[ "$rc" -eq 1 ]] || fail "save-images.sh without images must exit 1 (got $rc)"
grep -Fq 'No images' <<<"$out" ||
  fail "save-images.sh must explain that no images exist: $out"

mv "$dir/.env" "$dir/env-removed"
set +e
out="$(PATH="$dir/bin:$PATH" DOCKER_LOG="$dir/calls" bash "$dir/scripts/save-images.sh" 2>&1)"
rc=$?
set -e
[[ "$rc" -eq 1 ]] || fail "save-images.sh without .env must exit 1 (got $rc)"
grep -Fq 'Need .env' <<<"$out" ||
  fail "save-images.sh must explain the missing .env: $out"

echo "save-images.sh deduplicates images and refuses to run without images or .env"
