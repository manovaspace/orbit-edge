# Offline / air-gapped install

This stack does **not** require VPN, private forges, staff SSO, or a vendor cloud control plane.

## What you need on the offline host

- Docker Engine + Compose v2
- This repository (USB/git bundle)
- Image tarball from `./scripts/save-images.sh` (built on a networked machine)

## Builder (has internet)

```bash
cp .env.example .env
# set JWT_SECRET
docker compose --env-file .env build
./scripts/pin-images.sh
./scripts/save-images.sh /media/usb/orbit-edge-images.tar
# also copy this git tree or a release zip to the USB
```

## Offline host

```bash
docker load -i orbit-edge-images.tar
cp .env.example .env
# set JWT_SECRET (and change POSTGRES_PASSWORD)
# set ORBIT_*_IMAGE from images.lock if present
docker compose --env-file .env up -d
curl -sf http://127.0.0.1:10121/healthz
```

Mailpit UI (OTP inspection): `http://127.0.0.1:8025`  
Gateway HTTP: `http://127.0.0.1:10120`

## Password login (recommended offline)

Provision users in the `auth` database (admin SQL or future admin tooling). OTP still works if staff can open Mailpit on the LAN; it does not need the public internet when Mailpit is local.

## Out of scope

Staff SSO, private package registries, client product containers, and production edge reverse proxies belong in **your** deployment overlay — not this repo.
