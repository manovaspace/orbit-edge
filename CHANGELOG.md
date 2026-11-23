# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.0](https://github.com/manovaspace/orbit-edge/compare/v0.2.0...v0.3.0) (2026-11-22)


### ⚠ BREAKING CHANGES

* the gateway moved from 10120/10121 to 10001/10014 and is no longer published on all interfaces. Set GATEWAY_HTTP_PORT and GATEWAY_HEALTH_PORT to keep the old host ports.

### Features

* publish the gateway on registry ports, loopback only ([#32](https://github.com/manovaspace/orbit-edge/issues/32)) ([7aa1d35](https://github.com/manovaspace/orbit-edge/commit/7aa1d35a24501ee38c00d6959c5c7afa16026ca1))


### Code Refactoring

* drop references to the retired Orbit libraries; use orbit-kit ([#30](https://github.com/manovaspace/orbit-edge/issues/30)) ([b1005bd](https://github.com/manovaspace/orbit-edge/commit/b1005bdf1c897475709e61954c53c1b07109fca6))

## [0.2.0](https://github.com/manovaspace/orbit-edge/compare/v0.1.0...v0.2.0) (2026-11-03)


### Features

* **auth:** add the orbit-auth SaaS settings to the compose and env contract ([#21](https://github.com/manovaspace/orbit-edge/issues/21)) ([1ed7aa0](https://github.com/manovaspace/orbit-edge/commit/1ed7aa08726c8ca370da0252c88dd404853f2f51))

## 0.1.0 (2026-11-02)


### Bug Fixes

* register native edge quality check ([#9](https://github.com/manovaspace/orbit-edge/issues/9)) ([49a21fa](https://github.com/manovaspace/orbit-edge/commit/49a21fa39e79a853ed7ca9e467b6c7978fdfe642))


### Code Refactoring

* **compose:** update default MAILPIT_UI_PORT to 10825 ([80c10fd](https://github.com/manovaspace/orbit-edge/commit/80c10fd60473fb57fabb6e91ad4f3ad0728f06da))
* **compose:** update default MAILPIT_UI_PORT to 10825 ([010530b](https://github.com/manovaspace/orbit-edge/commit/010530b94e632af977a83cd7919df8f302316c0f))

## [Unreleased]

### Added

- Initial public MIT release.
