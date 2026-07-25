#!/usr/bin/env bash
# Save images for air-gapped transfer (run on a machine with network after build/pin).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
OUT="${1:-orbit-edge-images.tar}"

if [[ ! -f .env ]]; then
  echo "Need .env (for compose project)" >&2
  exit 1
fi

mapfile -t IDS < <(docker compose --env-file .env images -q | sort -u)
if [[ ${#IDS[@]} -eq 0 ]]; then
  echo "No images — run: docker compose --env-file .env build && docker compose --env-file .env up -d" >&2
  exit 1
fi

echo "Saving ${#IDS[@]} images to $OUT"
docker save -o "$OUT" "${IDS[@]}"
echo "Transfer $OUT plus this git checkout (or release tarball) to the offline host, then:"
echo "  docker load -i $OUT"
echo "  cp .env.example .env  # set secrets"
echo "  docker compose --env-file .env up -d"
