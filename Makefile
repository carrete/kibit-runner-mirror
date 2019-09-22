# -*- coding: utf-8; mode: make; -*-

SHELL = bash

DOCKER_REGISTRY = registry.gitlab.com
FULL_IMAGE_PATH = $(DOCKER_REGISTRY)/tvaughan/kibit-runner

GIT_REVISION = $(shell git rev-parse --short HEAD)
SYMBOLIC_REF = $(shell git rev-parse --abbrev-ref HEAD)

EXPLICIT_IMAGE = $(FULL_IMAGE_PATH):$(GIT_REVISION)
SYMBOLIC_IMAGE = $(FULL_IMAGE_PATH):$(SYMBOLIC_REF)

.PHONY: all
all: lint test

.PHONY: is-defined-%
is-defined-%:
	@$(if $(value $*),,$(error The environment variable $* is undefined))

.PHONY: login
login: is-defined-GITLAB_USERNAME is-defined-GITLAB_PASSWORD
	@echo "$(GITLAB_PASSWORD)" | docker login --username "$(GITLAB_USERNAME)" --password-stdin $(DOCKER_REGISTRY)

.PHONY: build
build: login
	@docker build --pull --tag $(EXPLICIT_IMAGE) .

.PHONY: lint test
lint test: build is-defined-CLOJARS_USERNAME is-defined-CLOJARS_PASSWORD
	@docker run --rm							\
	    --env CLOJARS_USERNAME="$(CLOJARS_USERNAME)"			\
	    --env CLOJARS_PASSWORD="$(CLOJARS_PASSWORD)"			\
	    --mount type=volume,src=kibit-runner-deps,dst=/root/.m2		\
            $(EXPLICIT_IMAGE)							\
	    make $@

.PHONY: repl shell
repl shell: build is-defined-CLOJARS_USERNAME is-defined-CLOJARS_PASSWORD
	@docker run --rm --interactive --tty --name localhost			\
	    --env CLOJARS_USERNAME="$(CLOJARS_USERNAME)"			\
	    --env CLOJARS_PASSWORD="$(CLOJARS_PASSWORD)"			\
	    --mount type=bind,src="$(PWD)"/kibit-runner,dst=/opt/kibit-runner	\
	    --mount type=volume,src=kibit-runner-deps,dst=/root/.m2		\
	    --publish 5309:5309							\
            $(EXPLICIT_IMAGE)							\
	    make $@

.PHONY: is-repo-clean
is-repo-clean:
	@git diff-index --quiet HEAD --

.PHONY: tag-image
tag-image: is-repo-clean build
	@docker tag $(EXPLICIT_IMAGE) $(SYMBOLIC_IMAGE)

.PHONY: push
push: tag-image
	@docker push $(FULL_IMAGE_PATH)

.PHONY: gitlab-runner-%
gitlab-runner-%: is-defined-CLOJARS_USERNAME is-defined-CLOJARS_PASSWORD
	@gitlab-runner exec docker --docker-privileged				\
	    --env CLOJARS_USERNAME="$(CLOJARS_USERNAME)"			\
	    --env CLOJARS_PASSWORD="$(CLOJARS_PASSWORD)"			\
	    $*
