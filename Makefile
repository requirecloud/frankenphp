PHONY :=

ifeq ($(shell uname -m),arm64)
	CURRENT_ARCH := arm64
else
	CURRENT_ARCH := amd64
endif

BAKE_FLAGS := --pull --no-cache --push
REPO_BASE := ghcr.io/requirecloud/frankenphp

# First tag of a bake target, e.g. $(call bake_tag,php-84)
bake_tag = $(shell docker buildx bake -f docker-bake.hcl --print $(1) 2>/dev/null | jq -r '.target["$(1)"].tags[0]')

PHONY += bake-all
bake-all: ## Bake all FrankenPHP images
	@docker buildx ls | grep -q ineen-buildx || docker buildx create --name=ineen-buildx --platform linux/amd64,linux/arm64
	@docker buildx use ineen-buildx
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
shell-test: IMG86 = $(call bake_tag,php-86)
shell-test:
	@docker run --rm -it \
		-v $(CURDIR)/frankenphp/all.jsonc:/root/.config/fastfetch/all.jsonc \
		$(IMG86) bash

PHONY += run-frankenphp-tests
run-frankenphp-tests: IMG84 = $(call bake_tag,php-84)
run-frankenphp-tests: IMG85 = $(call bake_tag,php-85)
run-frankenphp-tests: IMG86 = $(call bake_tag,php-86)
run-frankenphp-tests: IMGD84 = $(call bake_tag,drupal-84)
run-frankenphp-tests: IMGD85 = $(call bake_tag,drupal-85)
run-frankenphp-tests:
	$(call step,Run tests in $(IMG84))
	@docker run --rm -t -v $(CURDIR)/tests:/app $(IMG84) /app/tests.sh
	$(call step,Run tests in $(IMG85))
	@docker run --rm -t -v $(CURDIR)/tests:/app $(IMG85) /app/tests.sh
	$(call step,Run tests in $(IMG86))
	@docker run --rm -t -v $(CURDIR)/tests:/app $(IMG86) /app/tests.sh
	$(call step,Run tests in $(IMGD84))
	@docker run --rm -t -v $(CURDIR)/tests:/app $(IMGD84) /app/tests.sh drupal
	$(call step,Run tests in $(IMGD85))
	@docker run --rm -t -v $(CURDIR)/tests:/app $(IMGD85) /app/tests.sh drupal

PHONY += symfony-docker-update
symfony-docker-update:
	@update.sh

.PHONY: $(PHONY)
