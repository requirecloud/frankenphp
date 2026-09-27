# FrankenPHP Docker Images

Opinionated Docker images based on [FrankenPHP](https://frankenphp.dev), used as the base for Symfony and Drupal projects in this monorepo.

## Key Files

- `docker-bake.hcl` — build targets, upstream image references, and output tags
- `Dockerfile` — the actual image definition (extends `frankenphp_upstream` context)
- `Dockerfile.dist` — reference template synced from `dunglas/symfony-docker` via `update.sh`
- `Makefile` — build and test commands
- `frankenphp/` — Caddyfile, PHP ini configs, entrypoint scripts, fastfetch config
- `tests/` — test scripts run against built images

## Version Updates

Renovate opens PRs for new upstream tags (PHP patch releases and FrankenPHP releases). To update by hand:

1. **`docker-bake.hcl`** — update `UPSTREAM_PHP84` / `UPSTREAM_PHP85` (full upstream tag, e.g. `1.12.7-php8.4.26`). All output tags are derived from these, and the Makefile reads its tags from the bake file.
2. **`README.md`** — update the variants table and, on a FrankenPHP version change, the example `FROM` line

Check available upstream tags (PHP patch versions) before updating:
```
https://hub.docker.com/r/dunglas/frankenphp/tags?name=1.x.y-php8.
```

## CI

`.github/workflows/build.yml` runs on PRs, pushes to `main` (when image files change), weekly and manually:

- **build** — each target (`php-84`, `php-85`) is built on native amd64 and arm64 runners, tested with `tests/tests.sh`, and on `main` pushed untagged by digest
- **merge** — on `main` only, combines the per-arch digests into multi-arch manifests with the tags from `docker-bake.hcl`

The ghcr.io package must grant this repository's Actions write access.

## Build & Test Commands

```bash
make bake-local   # Build for local arch, load into Docker, run tests — use this to verify changes
make bake-all     # Build multi-arch (amd64 + arm64) and push to ghcr.io/requirecloud/frankenphp (CI normally does this)
make bake-print   # Dry-run: print the bake plan without building
make shell-test   # Open a shell in the php8.5 image for manual inspection
```

## Published Image

**Registry:** `ghcr.io/requirecloud/frankenphp`
**Architectures:** `linux/amd64`, `linux/arm64`

## What the Image Adds Over Upstream

Extensions installed via `install-php-extensions`:
- `@composer`, `apcu`, `intl`, `opcache`, `zip`

Additional apt packages: `acl`, `fastfetch`, `file`, `gettext`, `git`, `vim`

Custom files from `frankenphp/`:
- `Caddyfile` — base Caddy/FrankenPHP config
- `conf.d/10-app.ini` — shared PHP ini settings
- `docker-entrypoint.sh` — custom entrypoint
- `.bashrc`, `all.jsonc` — shell and fastfetch config
