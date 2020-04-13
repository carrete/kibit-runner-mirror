# -*- coding: utf-8; mode: makefile-gmake; -*-

MAKEFLAGS += --warn-undefined-variables

SHELL := bash
.SHELLFLAGS := $(or ${SHELLFLAGS},${SHELLFLAGS},-euo pipefail -c)

HERE := $(shell cd -P -- $(shell dirname -- $$0) && pwd -P)

DOCKER_REGISTRY := registry.gitlab.com
FULL_IMAGE_PATH := $(DOCKER_REGISTRY)/tvaughan/docker-native-image

GIT_REVISION := 21.0

EXPLICIT_IMAGE := $(FULL_IMAGE_PATH):$(GIT_REVISION)

PODMAN := $(HERE)/podman-wrapper
SRCDIR := /opt/kibit-runner

.PHONY: all
all: native-image

include .starterkit.mk

.PHONY: pull-latest
pull-latest:
	@$(PODMAN) pull $(EXPLICIT_IMAGE)

.PHONY: native-image shell
native-image shell: pull-latest
	@$(PODMAN) run --rm --interactive --tty --name native-image             \
	    --volume $(SRCDIR):/opt/kibit-runner                                \
	    --volume kibit-runner-deps:/root/.m2                                \
	    $(EXPLICIT_IMAGE)                                                   \
	    make -C /opt/kibit-runner $@
