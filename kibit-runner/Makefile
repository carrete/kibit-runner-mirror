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

.PHONY: build
build: is-in-container

.PHONY: shell
shell: build
	@bash --login

.PHONY: repl
repl: build
	@clojure -C:test -R:test -A:$@ --interactive --bind 0.0.0.0 --port 5309

.PHONY: check-format format
check-format format: build
	@clojure -C:test -R:test -A:cljfmt:$@

.PHONY: bikeshed
bikeshed: build
	@clojure -C:test -R:test -A:$@ -e "(System/exit 0)"  # TODO:

.PHONY: eastwood
eastwood: build
	@clojure -C:test -R:test -A:$@ '{:source-paths ["src"] :test-paths ["test"]}'

.PHONY: kibit
kibit: build
	@clojure -C:test -R:test -A:$@

.PHONY: lint
lint: check-format bikeshed eastwood kibit

.PHONY: test
test: build
	@clojure -A:$@

.PHONY: slamhound
slamhound: build
	@clojure -A:$@ .

.PHONY: compile
compile: build
	@mkdir -p dist
	@clojure -A:$@ dist/kibit-runner.jar

.PHONY: publish
publish: compile is-defined-CLOJARS_USERNAME is-defined-CLOJARS_PASSWORD
	@clojure -A:$@ deploy dist/kibit-runner.jar

.PHONY: update-deps
update-deps: build
	@clojure -A:outdated -a outdated,repl,cljfmt,bikeshed,eastwood,kibit,test,slamhound,compile,publish --update

.PHONY: pprint
pprint: build
	@clojure -Stree
