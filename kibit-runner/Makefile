# -*- coding: utf-8; mode: makefile-gmake; -*-

MAKEFLAGS += --warn-undefined-variables

SHELL := bash
.SHELLFLAGS := $(or ${SHELLFLAGS},${SHELLFLAGS},-euo pipefail -c)

HERE := $(shell cd -P -- $(shell dirname -- $$0) && pwd -P)

.PHONY: all
all: lint test

.PHONY: has-command-%
has-command-%:
	@$(if $(shell command -v $* 2> /dev/null),,$(error The command $* does not exist in PATH))

.PHONY: is-defined-%
is-defined-%:
	@$(if $(value $*),,$(error The environment variable $* is undefined))

define CONTAINER_REQUIRED_MESSAGE

This command must be run *inside* the container. Please use the Makefile in
the top-level directory of this project instead
endef

.PHONY: is-in-container
is-in-container:
	@$(if $(shell ls /.dockerenv /run/.containerenv 2>/dev/null),,$(error $(CONTAINER_REQUIRED_MESSAGE)))

.PHONY: shell
shell: is-in-container
	@bash --login

.PHONY: repl test check-refactor refactor eastwood
repl test check-refactor refactor eastwood: is-in-container
	@clojure -M:koacha:user:$@

.PHONY: check-format
check-format: is-in-container
	@cljstyle check .

.PHONY: format
format: is-in-container
	@cljstyle fix .

.PHONY: clj-kondo
clj-kondo: is-in-container
	@clj-kondo --lint .

.PHONY: lint
lint: check-format check-refactor eastwood clj-kondo

.PHONY: compile
compile: pom.xml
	@clojure -X:depstar:$@ :jar dist/kibit-runner.jar

.PHONY: uberjar
uberjar: pom.xml
	@clojure -X:depstar:$@ :jar dist/kibit-runner-standalone.jar :aot true :main-class kibit-runner.cmdline

.PHONY: publish
publish: compile is-defined-CLOJARS_USERNAME is-defined-CLOJARS_PASSWORD
	@clojure -M:$@ deploy dist/kibit-runner.jar

.PHONY: native-image
native-image: has-command-native-image uberjar
	@native-image                                                           \
	  -jar dist/kibit-runner-standalone.jar                                 \
	  dist/kibit-runner                                                     \
	  --allow-incomplete-classpath                                          \
	  --initialize-at-build-time                                            \
	  --no-server                                                           \
	  --report-unsupported-elements-at-runtime                              \
	  -H:+ReportExceptionStackTraces                                        \
	  -H:Name="kibit-runner"                                                \
	&& true

.PHONY: update-deps
update-deps: is-in-container
	@clojure -M:outdated --upgrade --force

pom.xml: is-in-container deps.edn
	@clojure -Spom

update-dependencies: update-deps pom.xml

.PHONY: pprint
pprint: is-in-container
	@clojure -Stree
