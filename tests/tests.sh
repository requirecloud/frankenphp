#!/usr/bin/env bash

. "$(dirname "$0")/utils.sh"
. "$(dirname "$0")/php.sh"

# Variant specific tests, e.g. "tests.sh drupal drupal-dev"
for variant in "$@"; do
  . "$(dirname "$0")/$variant.sh"
done

echo -e "\n\e[30;42mAll tests passed!\e[49m\n"

exit 0
