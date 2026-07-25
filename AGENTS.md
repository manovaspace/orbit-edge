# orbit-edge

Canonical offline/self-host compose for Orbit (auth + notifications + gateway). MIT — `github.com/manovaspace/orbit-edge`.

## Commands

```bash
cp .env.example .env   # set JWT_SECRET
docker compose --env-file .env config
docker compose --env-file .env up -d --build
./scripts/pin-images.sh
```

## Docs

- [README.md](./README.md)
- [docs/OFFLINE.md](./docs/OFFLINE.md)
- [docs/UPGRADE.md](./docs/UPGRADE.md)
