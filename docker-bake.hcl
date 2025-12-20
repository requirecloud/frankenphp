variable "REPO_BASE" {
  default = "ghcr.io/requirecloud/frankenphp"
}

group "default" {
  targets = [
    "php-84",
    "php-85",
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
    frankenphp_upstream = "docker-image://dunglas/frankenphp:1.11.0-php8.4.16"
  }
  tags = [
    "${REPO_BASE}:1.11.0-php8.4",
    "${REPO_BASE}:1.11.0-php8.4.16",

  ]
}

target "php-85" {
  inherits = ["common"]
  args = {
    PHP_VERSION = "8.5"
    PHP_SHORT_VERSION = "85"
  }
  contexts = {
    frankenphp_upstream = "docker-image://dunglas/frankenphp:1.11.0-php8.5.1"
  }
  tags = [
    "${REPO_BASE}:1.11.0-php8",
    "${REPO_BASE}:1.11.0-php8.5",
    "${REPO_BASE}:1.11.0-php8.5.1",
    "${REPO_BASE}:latest",
  ]
}
