#!/usr/bin/env bash

. "$(dirname "$0")/utils.sh"
. "$(dirname "$0")/php.sh"

# Variant specific tests, e.g. "tests.sh drupal"
if [[ -n "$1" ]]; then
  . "$(dirname "$0")/$1.sh"
fi

echo -e "\n\e[30;42mAll tests passed!\e[49m\n"

exit 0
