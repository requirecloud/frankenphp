# RequireCloud FrankenPHP Docker images

Opinionated Docker images based on [FrankenPHP](https://frankenphp.dev) ([repo](https://github.com/php/frankenphp)).

Setup is based on [dunglas/symfony-docker](https://github.com/dunglas/symfony-docker).

## Variants

| Image                           | Tag            | FrankenPHP | PHP |
|:--------------------------------|:---------------|:-----------|:----|
| ghcr.io/requirecloud/frankenphp | 1.8.0-php8     | 1.7.0      | 8.4 |
| ghcr.io/requirecloud/frankenphp | 1.7.0-php8.3   | 1.7.0      | 8.3 |
| ghcr.io/requirecloud/frankenphp | 1.7.0-php8.3.x | 1.7.0      | 8.3 |
| ghcr.io/requirecloud/frankenphp | 1.8.0-php8.4   | 1.7.0      | 8.4 |
| ghcr.io/requirecloud/frankenphp | 1.8.0-php8.4.x | 1.7.0      | 8.4 |
| ghcr.io/requirecloud/frankenphp | latest         | 1.7.0      | 8.4 |

All tags are released with `linux/amd64` and `linux/arm64` architecture.

## Extensions added

These are the extensions added with [install-php-extensions](https://github.com/mlocati/docker-php-extension-installer)

- @composer
- apcu
- intl
- opcache
- zip

## Example usage

In your `Dockerfile` it could be used e.g. like this:

```Dockerfile
#syntax=docker/dockerfile:1

FROM ghcr.io/requirecloud/frankenphp:1.8.0-php8.4.10 AS frankenphp_base

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

## TODO and Questions

- Add build and push workflow in GHA
- App specific Caddyfiles e.g. Drupal
- Should Vulcain be removed?
- Should mysql and postgresql be included?
