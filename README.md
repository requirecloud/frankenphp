# RequireCloud FrankenPHP Docker images

Opinionated Docker images based on `dunglas/frankenphp`.

## Variants

| Image                           | Tag            | FrankenPHP | PHP |
|---------------------------------|----------------|------------|-----|
| ghcr.io/requirecloud/frankenphp | 1.7.0-php8     | 1.7.0      | 8.4 |
| ghcr.io/requirecloud/frankenphp | 1.7.0-php8.3   | 1.7.0      | 8.3 |
| ghcr.io/requirecloud/frankenphp | 1.7.0-php8.3.x | 1.7.0      | 8.3 |
| ghcr.io/requirecloud/frankenphp | 1.7.0-php8.4   | 1.7.0      | 8.4 |
| ghcr.io/requirecloud/frankenphp | 1.7.0-php8.4.x | 1.7.0      | 8.4 |
| ghcr.io/requirecloud/frankenphp | latest         | 1.7.0      | 8.4 |

## Extensions added

These are the extensions added with [install-php-extensions](https://github.com/mlocati/docker-php-extension-installer)

- @composer
- apcu
- intl
- opcache
- zip

## TODO

- App specific Caddyfiles e.g. Drupal
- Should Vulcain be removed?
