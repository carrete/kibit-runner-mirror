# -*- coding: utf-8; mode: makefile-gmake; -*-

MAKEFLAGS += --warn-undefined-variables

SHELL := bash
.SHELLFLAGS := $(or ${SHELLFLAGS},${SHELLFLAGS},-euo pipefail -c)

HERE := $(shell cd -P -- $(shell dirname -- $$0) && pwd -P)

DOCKER_REGISTRY := registry.gitlab.com
FULL_IMAGE_PATH := $(DOCKER_REGISTRY)/tvaughan/kibit-runner

GIT_REVISION := $(shell git rev-parse --short HEAD)
SYMBOLIC_REF := $(shell git rev-parse --abbrev-ref HEAD)

EXPLICIT_IMAGE := $(FULL_IMAGE_PATH):$(GIT_REVISION)
SYMBOLIC_IMAGE := $(FULL_IMAGE_PATH):$(SYMBOLIC_REF)

PODMAN := $(HERE)/podman-wrapper
SRCDIR := /opt/kibit-runner

.PHONY: all
all: lint test

include .starterkit.mk

.PHONY: build
build:
	@$(PODMAN) build --pull --tag $(EXPLICIT_IMAGE) --cache-from $(EXPLICIT_IMAGE) .

.PHONY: export
export: is-repo-clean build
	@$(PODMAN) save -o kibit-runner-$(GIT_REVISION).tar $(EXPLICIT_IMAGE)

.PHONY: import
import:
	@if [[ ! -f kibit-runner-$(GIT_REVISION).tar ]]; then                   \
	    echo "kibit-runner-$(GIT_REVISION).tar does not exist";             \
	    exit 1;                                                             \
	fi
	@$(PODMAN) load -i kibit-runner-$(GIT_REVISION).tar

.PHONY: lint test publish
lint test publish: is-repo-clean build is-defined-CLOJARS_USERNAME is-defined-CLOJARS_PASSWORD
	@$(PODMAN) run --rm                                                     \
	    --env CLOJARS_USERNAME="$(CLOJARS_USERNAME)"                        \
	    --env CLOJARS_PASSWORD="$(CLOJARS_PASSWORD)"                        \
	    --volume kibit-runner-deps:/root/.m2                                \
	    $(EXPLICIT_IMAGE)                                                   \
	    make $@

.PHONY: repl shell
repl shell: build is-defined-CLOJARS_USERNAME is-defined-CLOJARS_PASSWORD
	@$(PODMAN) run --rm                                                     \
	    --interactive --tty --name kibit-runner                             \
	    --env CLOJARS_USERNAME="$(CLOJARS_USERNAME)"                        \
	    --env CLOJARS_PASSWORD="$(CLOJARS_PASSWORD)"                        \
	    --publish 5309:5309                                                 \
	    --volume $(SRCDIR):/opt/kibit-runner                                \
	    --volume kibit-runner-deps:/root/.m2                                \
	    $(EXPLICIT_IMAGE)                                                   \
	    make $@

.PHONY: tag-image
tag-image: is-repo-clean build
	@$(PODMAN) tag $(EXPLICIT_IMAGE) $(SYMBOLIC_IMAGE)

.PHONY: push
push: tag-image login
	@$(PODMAN) push $(EXPLICIT_IMAGE)
	@$(PODMAN) push $(SYMBOLIC_IMAGE)

.PHONY: exec-%
exec-%:
	@$(PODMAN) exec --interactive --tty kibit-runner make $*

.PHONY: gitlab-runner-%
gitlab-runner-%: is-defined-CLOJARS_USERNAME is-defined-CLOJARS_PASSWORD is-defined-GITLAB_USERNAME is-defined-GITLAB_PASSWORD
	@gitlab-runner exec docker --docker-privileged                          \
	    --env CLOJARS_USERNAME="$(CLOJARS_USERNAME)"                        \
	    --env CLOJARS_PASSWORD="$(CLOJARS_PASSWORD)"                        \
	    --env GITLAB_USERNAME="$(GITLAB_USERNAME)"                          \
	    --env GITLAB_PASSWORD="$(GITLAB_PASSWORD)"                          \
	    $*
