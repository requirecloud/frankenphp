#!/usr/bin/env bash

title "Test Drupal PHP extensions"
for ext in apcu gd pdo_mysql redis; do
  php -r "exit(extension_loaded('$ext') ? 0 : 1);" || error "PHP extension '$ext' is missing"
  info "$ext OK"
done

title "Test MySQL client"
(mysql --version && echo -e "") || error "Something wrong with MySQL client"

title "Test sendmail"
[[ "$(php -r 'echo ini_get("sendmail_path");')" == "/usr/sbin/sendmail -t -i" ]] || error "sendmail_path is not set"
[[ -x /usr/sbin/sendmail ]] || error "/usr/sbin/sendmail is missing"

title "Test Drupal Caddyfile"
(frankenphp validate --config /etc/frankenphp/Caddyfile 2>&1 | tail -1) || error "Caddyfile is not valid"
grep -q "DRUPAL_DOCROOT" /etc/frankenphp/Caddyfile || error "Drupal Caddyfile is not in place"

title "Test Drupal entrypoint"
grep -q "Drupal app ready" /usr/local/bin/docker-entrypoint || error "Drupal entrypoint is not in place"
command -v drush >/dev/null || [[ ":$PATH:" == *":/app/vendor/bin:"* ]] || error "/app/vendor/bin is not in PATH"
