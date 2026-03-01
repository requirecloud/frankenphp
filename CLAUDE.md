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

When updating FrankenPHP versions, three files need to change:

1. **`docker-bake.hcl`** — update `frankenphp_upstream` context image and output tags for both `php-84` and `php-85` targets
2. **`Makefile`** — update version references in `shell-test` and `run-frankenphp-tests` targets
3. **`README.md`** — update the variants table and the example `FROM` line

Check available upstream tags (PHP patch versions) before updating:
```
https://hub.docker.com/r/dunglas/frankenphp/tags?name=1.x.y-php8.
```

## Build & Test Commands

```bash
make bake-local   # Build for local arch, load into Docker, run tests — use this to verify changes
make bake-all     # Build multi-arch (amd64 + arm64) and push to ghcr.io/requirecloud/frankenphp
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
