# orbit-edge

[![CI](https://github.com/manovaspace/orbit-edge/actions/workflows/ci.yml/badge.svg)](https://github.com/manovaspace/orbit-edge/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](./LICENSE)

Canonical **self-host / offline** install for the Orbit toolkit: Postgres, Redis, Mailpit, `orbit-notifications`, `orbit-auth`, and `orbit-api-gateway`.

This is the one compose entry operators should use. Keep client apps and staff infra in separate overlays.

## Quick start

```bash
cp .env.example .env
# set JWT_SECRET — e.g. openssl rand -hex 32
docker compose --env-file .env up -d --build
curl -sf http://127.0.0.1:10121/healthz
```

| Port | Service |
| --- | --- |
| `10120` | API gateway HTTP |
| `10121` | Gateway health |
| `8025` | Mailpit UI (OTP email sink) |

Auth is gRPC-only inside the network; call auth via the gateway REST routes.

## Pin images / air-gap

```bash
./scripts/pin-images.sh      # writes images.lock (+ compose.images.yaml)
./scripts/save-images.sh     # docker save for USB transfer
```

See [docs/OFFLINE.md](./docs/OFFLINE.md) and [docs/UPGRADE.md](./docs/UPGRADE.md).

## What this is not

- Not Manova staff infra (no staff SSO, private forges, or prod reverse proxies)
- Not a place for client product containers
- Not multi-tenant SaaS — one Edge deployment = one site

## Components

Built from public sources:

- https://github.com/manovaspace/orbit-auth
- https://github.com/manovaspace/orbit-notifications
- https://github.com/manovaspace/orbit-api-gateway

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md). Security: [SECURITY.md](./SECURITY.md).

## License

MIT — see [LICENSE](./LICENSE).
