# -*- coding: utf-8; mode: makefile-gmake; -*-

MAKEFLAGS += --warn-undefined-variables

SHELL := bash
.SHELLFLAGS := $(or ${SHELLFLAGS},${SHELLFLAGS},-euo pipefail -c)

.PHONY: has-command-%
has-command-%:
	@$(if $(shell command -v $* 2> /dev/null),,$(error The command $* does not exist in PATH))

.PHONY: is-defined-%
is-defined-%:
	@$(if $(value $*),,$(error The environment variable $* is undefined))

.PHONY: is-repo-clean
is-repo-clean:
	@git diff-index --quiet HEAD --

.PHONY: login
login: is-defined-GITLAB_USERNAME is-defined-GITLAB_PASSWORD is-defined-DOCKER_REGISTRY is-defined-PODMAN
	@echo "$(GITLAB_PASSWORD)" | $(PODMAN) login --username $(GITLAB_USERNAME) --password-stdin $(DOCKER_REGISTRY)
