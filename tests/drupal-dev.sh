#!/usr/bin/env bash

title "Test Drupal dev image"
php -r "exit(extension_loaded('xdebug') ? 0 : 1);" || error "PHP extension 'xdebug' is missing"
info "xdebug OK"
[[ "$(php -r 'echo ini_get("display_errors");')" =~ ^(1|On|STDOUT)$ ]] || error "php.ini-development is not in use"
info "php.ini-development OK"
[[ "$APP_ENV" == "dev" ]] || error "APP_ENV should be dev, is '$APP_ENV'"
