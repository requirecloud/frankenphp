#!/bin/sh
set -e

if [ "$1" = 'frankenphp' ] || [ "$1" = 'php' ] || [ "$1" = 'drush' ]; then
	if [ -z "$(ls -A 'vendor/' 2>/dev/null)" ]; then
		composer install --prefer-dist --no-progress --no-interaction
	fi

	# Make the files directory writable for www-data, e.g. a volume in production.
	# In development it is bind mounted from the host and writable as is.
	FILES_DIR="$DRUPAL_DOCROOT/sites/default/files"
	if [ "$APP_ENV" != 'dev' ] && [ -d "$FILES_DIR" ]; then
		setfacl -R -m u:www-data:rwX -m u:"$(whoami)":rwX "$FILES_DIR"
		setfacl -dR -m u:www-data:rwX -m u:"$(whoami)":rwX "$FILES_DIR"
	fi

	# Configure msmtp (sendmail) when an SMTP relay is given
	if [ -n "$SMTP_HOST" ]; then
		cat > /etc/msmtprc <<-EOT
			defaults
			auth on
			tls on
			tls_trust_file /etc/ssl/certs/ca-certificates.crt
			logfile /dev/stdout

			account default
			host $SMTP_HOST
			port ${SMTP_PORT:-587}
			user $SMTP_USER
			password $SMTP_PASSWORD
			from $SMTP_FROM
		EOT
		chmod 600 /etc/msmtprc
	fi

	echo "Drupal app ready! (APP_ENV=$APP_ENV)"
fi

exec docker-php-entrypoint "$@"
