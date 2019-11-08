# -*- coding: utf-8; mode: make; -*-

SHELL = bash

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

.PHONY: repl check-refactor refactor bikeshed eastwood clj-kondo
repl check-refactor refactor bikeshed eastwood clj-kondo: is-in-container
	@clojure -C:test -R:test -A:$@

.PHONY: check-format format
check-format format: is-in-container
	@clojure -C:test -R:test -A:cljfmt:$@ .

.PHONY: lint
lint: check-format check-refactor bikeshed eastwood clj-kondo

.PHONY: test
test: is-in-container
	@clojure -A:$@

.PHONY: slamhound
slamhound: is-in-container
	@clojure -A:$@ .

.PHONY: compile
compile: is-in-container
	@clojure -A:$@ dist/kibit-runner.jar

.PHONY: publish
publish: compile is-defined-CLOJARS_USERNAME is-defined-CLOJARS_PASSWORD
	@clojure -A:$@ deploy dist/kibit-runner.jar

.PHONY: update-deps
update-deps: is-in-container
	@clojure -A:outdated -a outdated,repl,cljfmt,bikeshed,eastwood,clj-kondo,test,slamhound,compile,publish --update

.PHONY: pprint
pprint: is-in-container
	@clojure -Stree
