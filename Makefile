PHONY :=

ifeq ($(shell uname -m),arm64)
	CURRENT_ARCH := arm64
else
	CURRENT_ARCH := amd64
endif

BAKE_FLAGS := --pull --no-cache --push
REPO_BASE := ghcr.io/requirecloud/frankenphp

PHONY += bake-all
bake-all: ## Bake all FrankenPHP images
	@docker buildx bake -f docker-bake.hcl $(BAKE_FLAGS)

PHONY += bake-print
bake-print: BAKE_FLAGS := --print
bake-print: bake-all ## Print bake plan for FrankenPHP images

PHONY += bake-local
bake-local: BAKE_FLAGS := --pull --progress plain --no-cache --load --set *.platform=linux/$(CURRENT_ARCH)
bake-local: bake-all run-frankenphp-tests ## Bake all FrankenPHP images locally

PHONY += bake-test
bake-test: BAKE_FLAGS := --pull --progress plain --no-cache
bake-test: bake-all run-frankenphp-tests ## CI test for FrankenPHP images

PHONY += shell-test
shell-test: IMG84 := $(REPO_BASE):1.11.0-php8.5
shell-test:
	@docker run --rm -it \
		-v $(CURDIR)/frankenphp/all.jsonc:/root/.config/fastfetch/all.jsonc \
		$(IMG84) bash

PHONY += run-frankenphp-tests
run-frankenphp-tests: IMG84 := $(REPO_BASE):1.11.0-php8.4
run-frankenphp-tests: IMG85 := $(REPO_BASE):1.11.0-php8.5
run-frankenphp-tests:
	$(call step,Run tests in $(IMG84))
	@docker run --rm -t -v $(CURDIR)/tests:/app $(IMG84) /app/tests.sh
	$(call step,Run tests in $(IMG85))
	@docker run --rm -t -v $(CURDIR)/tests:/app $(IMG85) /app/tests.sh

PHONY += symfony-docker-update
symfony-docker-update:
	@update.sh

.PHONY: $(PHONY)
