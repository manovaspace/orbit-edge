# Releasing orbit-edge

`orbit-edge` is an MIT-licensed Docker Compose bundle for offline and self-hosted Orbit (auth,
notifications and gateway). It builds and publishes no image of its own: `scripts/pin-images.sh`
pins upstream images. A release ends at the git tag and its GitHub release notes.

## How a release happens

Write Conventional Commit messages and merge them into `main` through a pull request. On every push
to `main`, the `release-please` workflow opens or updates one bot release pull request titled
`chore(main): release X.Y.Z`. That pull request runs the repository's CI. When it is green and
reviewed, a maintainer merges it, and the same workflow creates the `vX.Y.Z` tag and the GitHub
release with the generated notes. Nobody bumps a version or pushes a tag by hand.

Merging the release pull request does nothing else: no image is built and nothing is deployed.
Self-hosters upgrade from their own checkout with `docker compose --env-file .env up -d --build`
and `./scripts/pin-images.sh`.

The release branch (`release-please--branches--main`) exists only while the pull request is open.
There is no long-lived release branch and no demo branch (ADR-044 D2).

## Conventional Commit types and what bumps

| Commit | Bump |
| --- | --- |
| `feat:` / `feature:` | MINOR |
| `fix:`, `perf:`, `refactor:`, `revert:` | PATCH |
| `!` after the type or scope (`feat!:`, `fix(api)!:`), or a `BREAKING CHANGE:` footer | MAJOR |
| `chore:`, `docs:`, `ci:`, `test:`, `style:`, `build:` | none |
| any type not listed above | none |

`refactor:` bumps a patch because `release-please-config.json` lists it as a visible changelog
section; the release-please defaults would hide it and release nothing. A release pull request
appears only when at least one merged commit has a visible section, so a docs-only or CI-only change
does not create one. Squash titles are the commit subject on `main`, so the pull request title must
also be a Conventional Commit.

No `v*` tag existed when the bot was configured, so `.release-please-manifest.json` starts at
`0.0.0`. The first release pull request proposes `0.1.0` because the configuration sets
`initial-version` to `0.1.0`; later bumps follow the table. The `simple` release type keeps the
version in `version.txt` at the repository root.

## How to read the release pull request

- **Title** — `chore(main): release X.Y.Z`.
- **Branch** — `release-please--branches--main`.
- **Label** — `autorelease: pending` until the release is tagged.
- **Files** — only `CHANGELOG.md` (a new version section), `version.txt` (the new version) and
  `.release-please-manifest.json` (the new version). Any other changed file means the release pull
  request is wrong.
- **Body** — the commits and the notes for the proposed version. It updates as new commits land on
  `main`, and the proposed version grows with them.

`CHANGELOG.md` is hand-maintained: release-please prepends a version section above it and the
existing `[Unreleased]` section stays.

Never edit the release pull request by hand except to resolve a genuine conflict in `CHANGELOG.md`.
Land the conflicting change on `main` and let the bot rebuild the pull request.

## The check on the release pull request

This repository has no release-tier check: there is no `release-check.yml` and no `manovaspace/ci`
release-tier caller here. The release pull request runs the ordinary CI workflow,
`.github/workflows/ci.yml`, on `pull_request` to `main`: it validates `docker compose config` from
`.env.example` and shellchecks `scripts/*.sh`. CodeQL runs weekly and on demand, not on the release
pull request.

Do not merge while this check is red or pending. `o pr merge` refuses in both cases (ADR-037).

## What merging does

The merge push runs `release-please` again. It creates the tag `vX.Y.Z` on `main` and publishes a
GitHub release whose notes come from the `CHANGELOG.md` entry, then relabels the pull request
`autorelease: tagged`.

Nothing else happens. No image is built, pushed or pinned, and no host is deployed: this repository
is a Compose bundle that self-hosters run themselves.

## Rollback

Do not move or force-push a published tag. If a release is wrong, revert the change through a `fix:`
or `revert:` pull request and let the bot publish the next patch. Self-hosters pin a tag in their own
checkout, so a bad tag is fixed by releasing a newer one rather than by moving the old one.

If a tag should never have existed and no consumer could have fetched it, the owner may delete the
GitHub release and the tag, then revert the release commit on `main` through a pull request. Deleting
a tag is destructive and needs the owner.

## Who approves

The bot never merges its own pull request. A maintainer reviews the release pull request and merges
it with `o pr merge`, which refuses while checks fail or are pending (ADR-037).

## Secrets used

Names only — never put a value in this file.

| Secret | Used by | Purpose |
| --- | --- | --- |
| `RELEASE_TOKEN` | `release-please` workflow | Personal access token so the release pull request triggers its own checks |

If `RELEASE_TOKEN` is empty, the `release-please` workflow prints `RELEASE_TOKEN not set, skipping`
and succeeds without opening a release pull request.
