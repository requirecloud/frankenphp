#syntax=docker/dockerfile:1

# Base FrankenPHP image
FROM frankenphp_upstream AS frankenphp_base

# defaults, copied from original frankenphp_dev stage
ENV APP_ENV=dev
ENV XDEBUG_MODE=off
ENV FRANKENPHP_WORKER_CONFIG=watch

WORKDIR /app

VOLUME /app/var/

# persistent / runtime deps
# hadolint ignore=DL3008
RUN apt-get update && apt-get install -y --no-install-recommends \
	acl \
    fastfetch \
	file \
	gettext \
	git \
    vim \
	&& rm -rf /var/lib/apt/lists/*

RUN set -eux; \
	install-php-extensions \
		@composer \
		intl \
		mbstring \
		opcache \
		zip \
	;

# https://getcomposer.org/doc/03-cli.md#composer-allow-superuser
ENV COMPOSER_ALLOW_SUPERUSER=1

ENV PHP_INI_SCAN_DIR=":$PHP_INI_DIR/app.conf.d"

###> recipes ###
###< recipes ###

###> requirecloud changes ###
ENV PATH="${PATH}:/root/.composer/vendor/bin"
###< requirecloud changes ###

COPY --link frankenphp/conf.d/10-app.ini $PHP_INI_DIR/app.conf.d/
COPY --link --chmod=755 frankenphp/docker-entrypoint.sh /usr/local/bin/docker-entrypoint
COPY --link frankenphp/Caddyfile /etc/frankenphp/Caddyfile
COPY --link frankenphp/.bashrc /root/.bashrc
COPY --link frankenphp/all.jsonc /root/.config/fastfetch/all.jsonc

ENTRYPOINT ["docker-entrypoint"]

HEALTHCHECK --start-period=60s CMD curl -f http://localhost:2019/metrics || exit 1
CMD [ "frankenphp", "run", "--config", "/etc/frankenphp/Caddyfile" ]

# Handle dev and prod in project

# Drupal image
FROM frankenphp_base AS frankenphp_drupal

# hadolint ignore=DL3008
RUN apt-get update && apt-get install -y --no-install-recommends \
	default-mysql-client \
	msmtp-mta \
	&& rm -rf /var/lib/apt/lists/*

RUN set -eux; \
	install-php-extensions \
		apcu \
		gd \
		pdo_mysql \
		redis \
	;

RUN echo 'sendmail_path = "/usr/sbin/sendmail -t -i"' > "$PHP_INI_DIR/conf.d/msmtp.ini"

# Copy, not move, so projects doing `mv php.ini-* php.ini` keep working
RUN cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

ENV APP_ENV=prod
ENV DRUPAL_DOCROOT=/app/public
ENV PATH="/app/vendor/bin:${PATH}"

COPY --link frankenphp/drupal/Caddyfile /etc/frankenphp/Caddyfile
COPY --link --chmod=755 frankenphp/drupal/docker-entrypoint.sh /usr/local/bin/docker-entrypoint

# Drupal development image
FROM frankenphp_drupal AS frankenphp_drupal_dev

ENV APP_ENV=dev

RUN cp "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

# Disabled by default with XDEBUG_MODE=off from the base image
RUN install-php-extensions xdebug

CMD [ "frankenphp", "run", "--config", "/etc/frankenphp/Caddyfile", "--watch" ]
