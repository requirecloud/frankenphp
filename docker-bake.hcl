variable "REPO_BASE" {
  default = "ghcr.io/requirecloud/frankenphp"
}

group "default" {
  targets = [
    "php-83",
    "php-84"
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
    "org.opencontainers.image.created" = "${timestamp()}"
  }
}

#
# FRANKENPHP
#

target "php-83" {
  inherits = ["common"]
  args = {
    PHP_VERSION = "8.3"
    PHP_SHORT_VERSION = "83"
  }
  contexts = {
    frankenphp_upstream = "docker-image://dunglas/frankenphp:1.9.0-php8.3.23"
  }
  tags = [
    "${REPO_BASE}:1.8.0-php8.3",
    "${REPO_BASE}:1.8.0-php8.3.23"
  ]
}

target "php-84" {
  inherits = ["common"]
  args = {
    PHP_VERSION = "8.4"
    PHP_SHORT_VERSION = "84"
  }
  contexts = {
    frankenphp_upstream = "docker-image://dunglas/frankenphp:1.9.0-php8.4.10"
  }
  tags = [
    "${REPO_BASE}:1.9.0-php8",
    "${REPO_BASE}:1.9.0-php8.4",
    "${REPO_BASE}:1.9.0-php8.4.10",
    "${REPO_BASE}:latest"
  ]
}
