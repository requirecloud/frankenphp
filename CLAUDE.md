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

1. **`docker-bake.hcl`** — update `UPSTREAM_PHP84` / `UPSTREAM_PHP85` / `UPSTREAM_PHP86` (full upstream tag, e.g. `1.12.7-php8.4.26`). All output tags are derived from these, and the Makefile reads its tags from the bake file.
2. **`README.md`** — update the variants table and, on a FrankenPHP version change, the example `FROM` line

Check available upstream tags (PHP patch versions) before updating:
```
https://hub.docker.com/r/dunglas/frankenphp/tags?name=1.x.y-php8.
```

## CI

`.github/workflows/build.yml` runs on PRs, pushes to `main` (when image files change), weekly and manually:

- **build** — each target (`php-84`, `php-85`, `php-86`, `drupal-84`, `drupal-85`) is built on native amd64 and arm64 runners, tested with `tests/tests.sh`, and on `main` pushed untagged by digest
- **merge** — on `main` only, combines the per-arch digests into multi-arch manifests with the tags from `docker-bake.hcl`

The ghcr.io package must grant this repository's Actions write access.

## Build & Test Commands

```bash
make bake-local   # Build for local arch, load into Docker, run tests — use this to verify changes
make bake-all     # Build multi-arch (amd64 + arm64) and push to ghcr.io/requirecloud/frankenphp (CI normally does this)
make bake-print   # Dry-run: print the bake plan without building
make shell-test   # Open a shell in the php8.6 image for manual inspection
```

## Published Images

**Registry:** `ghcr.io/requirecloud/frankenphp` (targets `php-*`) and `ghcr.io/requirecloud/frankenphp-drupal` (targets `drupal-*`)
**Architectures:** `linux/amd64`, `linux/arm64`

## What the Image Adds Over Upstream

Extensions installed via `install-php-extensions`:
- `@composer`, `intl`, `mbstring`, `opcache`, `zip`
- `apcu` is intentionally not included (differs from `Dockerfile.dist`); projects that need it, like Drupal, install it themselves

Additional apt packages: `acl`, `fastfetch`, `file`, `gettext`, `git`, `vim`

## Drupal Image

The `frankenphp_drupal` stage in `Dockerfile` builds on `frankenphp_base` and adds `apcu`, `gd`, `pdo_mysql`, `redis`,
`default-mysql-client` and `msmtp-mta` (as PHP `sendmail_path`). Targets `drupal-84` / `drupal-85` inherit the PHP version
from `php-84` / `php-85`; there is no 8.6 variant until apcu and redis support it. Tests: `tests/tests.sh drupal` also runs
`tests/drupal.sh`. The `common` target sets `target = "frankenphp_base"`, as the last stage is the Drupal one.

Custom files from `frankenphp/`:
- `Caddyfile` — base Caddy/FrankenPHP config
- `conf.d/10-app.ini` — shared PHP ini settings
- `docker-entrypoint.sh` — custom entrypoint
- `.bashrc`, `all.jsonc` — shell and fastfetch config
