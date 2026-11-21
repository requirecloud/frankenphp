variable "REPO_BASE" {
  default = "ghcr.io/requirecloud/frankenphp"
}

# Upstream dunglas/frankenphp tags, all output tags are derived from these
variable "UPSTREAM_PHP84" {
  # renovate: datasource=docker depName=dunglas/frankenphp
  default = "1.14.0-php8.4.28"
}

variable "UPSTREAM_PHP85" {
  # renovate: datasource=docker depName=dunglas/frankenphp
  default = "1.14.0-php8.5.13"
}

variable "UPSTREAM_PHP86" {
  # renovate: datasource=docker depName=dunglas/frankenphp
  default = "1.14.0-php8.6.0"
}

# "1.12.7-php8.4.26" => "1.12.7"
function "frankenphp_version" {
  params = [tag]
  result = split("-php", tag)[0]
}

group "default" {
  targets = [
    "php-84",
    "php-85",
    "php-86",
  ]
}

target "common" {
  context = "./"
  dockerfile = "./Dockerfile"
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
  labels = {
    "org.opencontainers.image.url" = "https://github.com/requirecloud/frankenphp"
    "org.opencontainers.image.source" = "https://github.com/requirecloud/frankenphp"
    "org.opencontainers.image.licenses" = "MIT"
    "org.opencontainers.image.vendor" = "RequireCloud"
    "org.opencontainers.image.created" = timestamp()
  }
}

#
# FRANKENPHP
#

target "php-84" {
  inherits = ["common"]
  args = {
    PHP_VERSION = "8.4"
    PHP_SHORT_VERSION = "84"
  }
  contexts = {
    frankenphp_upstream = "docker-image://dunglas/frankenphp:${UPSTREAM_PHP84}"
  }
  tags = [
    "${REPO_BASE}:${frankenphp_version(UPSTREAM_PHP84)}-php8.4",
    "${REPO_BASE}:${UPSTREAM_PHP84}",
  ]
}

target "php-85" {
  inherits = ["common"]
  args = {
    PHP_VERSION = "8.5"
    PHP_SHORT_VERSION = "85"
  }
  contexts = {
    frankenphp_upstream = "docker-image://dunglas/frankenphp:${UPSTREAM_PHP85}"
  }
  tags = [
    "${REPO_BASE}:${frankenphp_version(UPSTREAM_PHP85)}-php8.5",
    "${REPO_BASE}:${UPSTREAM_PHP85}",
  ]
}

target "php-86" {
  inherits = ["common"]
  args = {
    PHP_VERSION = "8.6"
    PHP_SHORT_VERSION = "86"
  }
  contexts = {
    frankenphp_upstream = "docker-image://dunglas/frankenphp:${UPSTREAM_PHP86}"
  }
  tags = [
    "${REPO_BASE}:${frankenphp_version(UPSTREAM_PHP86)}-php8",
    "${REPO_BASE}:${frankenphp_version(UPSTREAM_PHP86)}-php8.6",
    "${REPO_BASE}:${UPSTREAM_PHP86}",
    "${REPO_BASE}:latest",
  ]
}
