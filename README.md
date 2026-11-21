# RequireCloud FrankenPHP Docker images

Opinionated Docker images based on [FrankenPHP](https://frankenphp.dev) ([repo](https://github.com/php/frankenphp)).

Setup is based on [dunglas/symfony-docker](https://github.com/dunglas/symfony-docker).

## Variants

| Image                           | Tag              | FrankenPHP | PHP    |
|:--------------------------------|:-----------------|:-----------|:-------|
| ghcr.io/requirecloud/frankenphp | 1.14.0-php8.4    | 1.14.0     | 8.4.28 |
| ghcr.io/requirecloud/frankenphp | 1.14.0-php8.4.28 | 1.14.0     | 8.4.28 |
| ghcr.io/requirecloud/frankenphp | 1.14.0-php8.5    | 1.14.0     | 8.5.13 |
| ghcr.io/requirecloud/frankenphp | 1.14.0-php8.5.13 | 1.14.0     | 8.5.13 |
| ghcr.io/requirecloud/frankenphp | 1.14.0-php8      | 1.14.0     | 8.6.0  |
| ghcr.io/requirecloud/frankenphp | 1.14.0-php8.6    | 1.14.0     | 8.6.0  |
| ghcr.io/requirecloud/frankenphp | 1.14.0-php8.6.0  | 1.14.0     | 8.6.0  |
| ghcr.io/requirecloud/frankenphp | latest           | 1.14.0     | 8.6.0  |

All tags are released with `linux/amd64` and `linux/arm64` architecture.

### Drupal

`ghcr.io/requirecloud/frankenphp-drupal` is built on top of the base image above, with what Drupal projects
need preinstalled. There is no PHP 8.6 variant yet, as `apcu` and `redis` have no release supporting it.

| Image                                  | Tag              | FrankenPHP | PHP    |
|:---------------------------------------|:-----------------|:-----------|:-------|
| ghcr.io/requirecloud/frankenphp-drupal | 1.14.0-php8.4    | 1.14.0     | 8.4.28 |
| ghcr.io/requirecloud/frankenphp-drupal | 1.14.0-php8.4.28 | 1.14.0     | 8.4.28 |
| ghcr.io/requirecloud/frankenphp-drupal | 1.14.0-php8      | 1.14.0     | 8.5.13 |
| ghcr.io/requirecloud/frankenphp-drupal | 1.14.0-php8.5    | 1.14.0     | 8.5.13 |
| ghcr.io/requirecloud/frankenphp-drupal | 1.14.0-php8.5.13 | 1.14.0     | 8.5.13 |
| ghcr.io/requirecloud/frankenphp-drupal | latest           | 1.14.0     | 8.5.13 |

Every tag also has a `-dev` variant (e.g. `1.14.0-php8.5.13-dev`, `latest-dev`) for local development.

In addition to the base image it has:

- PHP extensions: `apcu`, `gd`, `pdo_mysql`, `redis`
- `default-mysql-client` (for e.g. `drush sql:*`)
- `msmtp-mta` as `sendmail`, with PHP `sendmail_path` set to it
- `php.ini-production` as `php.ini` and `APP_ENV=prod`
- `/app/vendor/bin` in `PATH` (e.g. `drush`)
- Drupal [Caddyfile](frankenphp/drupal/Caddyfile): docroot from `DRUPAL_DOCROOT` (default `/app/public`), blocks
  `update.php` and private files, caches static files and sets security headers. Add your own directives with
  `CADDY_SERVER_EXTRA_DIRECTIVES`.
- Drupal [entrypoint](frankenphp/drupal/docker-entrypoint.sh): runs `composer install` if `vendor/` is empty, makes
  `sites/default/files` writable for `www-data` (not in dev) and configures msmtp when `SMTP_HOST` is set
  (`SMTP_PORT`, `SMTP_USER`, `SMTP_PASSWORD`, `SMTP_FROM`)

The `-dev` variant adds `xdebug` (off by default, set `XDEBUG_MODE`), `php.ini-development`, `APP_ENV=dev`
and runs FrankenPHP with `--watch`.

```Dockerfile
FROM ghcr.io/requirecloud/frankenphp-drupal:1.14.0-php8.5-dev AS frankenphp_dev

FROM ghcr.io/requirecloud/frankenphp-drupal:1.14.0-php8.5 AS frankenphp_prod

COPY --link composer.* ./
RUN composer install --no-cache --prefer-dist --no-dev --no-autoloader --no-scripts --no-progress
COPY --link public ./public
RUN composer dump-autoload --classmap-authoritative --no-dev && composer run-script --no-dev post-install-cmd
```

## Extensions added

These are the extensions added with [install-php-extensions](https://github.com/mlocati/docker-php-extension-installer)

- @composer
- intl
- mbstring
- opcache
- zip

`apcu` was included up to FrankenPHP 1.13.x images. If you need it, install it in your own `Dockerfile` or
use the Drupal image. Note that apcu has no release supporting PHP 8.6 yet.

## Example usage

In your `Dockerfile` it could be used e.g. like this:

```Dockerfile
#syntax=docker/dockerfile:1

FROM ghcr.io/requirecloud/frankenphp:1.14.0-php8.6 AS frankenphp_base

# Install additional extensions
RUN apt-get update && \
    apt-get install -y --no-install-recommends default-mysql-client && \
    install-php-extensions \
        pdo_mysql \
        gd \
        redis

ENV PATH="/app/vendor/bin:${PATH}"

# Development image
FROM frankenphp_base AS frankenphp_dev

RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
RUN install-php-extensions xdebug

CMD [ "frankenphp", "run", "--config", "/etc/frankenphp/Caddyfile", "--watch" ]

# Production image
FROM frankenphp_base AS frankenphp_prod

ENV APP_ENV=prod
ENV FRANKENPHP_CONFIG="import worker.Caddyfile"

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# prevent the reinstallation of vendors at every changes in the source code
COPY --link composer.* ./
RUN set -eux; \
	composer install --no-cache --prefer-dist --no-dev --no-autoloader --no-scripts --no-progress

# copy sources
COPY --link . ./
RUN rm -Rf frankenphp/ patches/

RUN set -eux; \
	mkdir -p var/cache var/log; \
	composer dump-autoload --classmap-authoritative --no-dev; \
	composer run-script --no-dev post-install-cmd;  \
  sync;
```
