# Upgrade and rollback

Orbit Edge pins **application** images via `images.lock` (image IDs) after `./scripts/pin-images.sh`. Base images (Postgres, Redis, Mailpit) are tagged in `compose.yaml`; re-pin after upgrades.

## Upgrade (online)

1. Read the release notes for the Edge tag you want (e.g. `v0.1.0`).
2. Back up Postgres:  
   `docker compose --env-file .env exec -T postgres pg_dumpall -U orbit > backup-$(date -u +%Y%m%d).sql`
3. Update this repo to the target tag:  
   `git fetch --tags && git checkout v0.1.0`
4. Set `ORBIT_*_REF` in `.env` to matching service tags/commits (or leave `main` only for lab use).
5. Rebuild and restart:  
   `docker compose --env-file .env up -d --build`
6. Re-pin: `./scripts/pin-images.sh` and commit `images.lock` in your private deployment overlay (not required upstream).
7. Smoke-test: `curl -sf http://127.0.0.1:10121/healthz`

## Rollback

1. Restore the previous Edge git tag (or previous `images.lock`).
2. `docker compose --env-file .env down`
3. If schema migrations are incompatible, restore the Postgres dump from step 2 of the upgrade.
4. `docker compose --env-file .env up -d` (with pinned image IDs from the old `images.lock` when present).

## Air-gapped upgrade

1. On a networked builder: checkout the new Edge tag, `docker compose build`, `./scripts/save-images.sh bundle.tar`
2. Copy `bundle.tar` + the Edge release tree to the offline host.
3. `docker load -i bundle.tar` then follow Upgrade steps 5–7 (no `--build` if images already loaded — set `ORBIT_*_IMAGE` from `images.lock`).

Never deploy without a Postgres backup when crossing migration versions in `orbit-auth` / `orbit-notifications`.
