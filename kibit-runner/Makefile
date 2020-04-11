# -*- coding: utf-8; mode: makefile-gmake; -*-

MAKEFLAGS += --warn-undefined-variables

SHELL := bash
.SHELLFLAGS := $(or ${SHELLFLAGS},${SHELLFLAGS},-euo pipefail -c)

HERE := $(shell cd -P -- $(shell dirname -- $$0) && pwd -P)

.PHONY: all
all: lint test

.PHONY: is-defined-%
is-defined-%:
	@$(if $(value $*),,$(error The environment variable $* is undefined))

define CONTAINER_REQUIRED_MESSAGE

This command must be run *inside* the container. Please use the Makefile in
the top-level directory of this project instead
endef

.PHONY: is-in-container
is-in-container:
	@$(if $(wildcard /.docker*),,$(error $(CONTAINER_REQUIRED_MESSAGE)))

.PHONY: shell
shell: is-in-container
	@bash --login

.PHONY: repl test check-format format check-refactor refactor eastwood kondo
repl test check-format format check-refactor refactor eastwood kondo: is-in-container
	@clojure -A:test:cljstyle:$@

.PHONY: joker
joker: is-in-container
	@joker --lint --working-dir .

.PHONY: lint
lint: check-format check-refactor eastwood kondo joker

.PHONY: bump-pom
bump-pom: is-in-container
	@clojure -Spom

.PHONY: compile
compile: is-in-container
	@clojure -A:$@ dist/kibit-runner.jar

.PHONY: publish
publish: compile is-defined-CLOJARS_USERNAME is-defined-CLOJARS_PASSWORD
	@clojure -A:$@ deploy dist/kibit-runner.jar

.PHONY: update-deps
update-deps: is-in-container
	@clojure -A:outdated --update

.PHONY: pprint
pprint: is-in-container
	@clojure -Stree
