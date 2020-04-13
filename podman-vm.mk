# -*- coding: utf-8; mode: makefile-gmake; -*-

MAKEFLAGS += --warn-undefined-variables

SHELL := bash
.SHELLFLAGS := $(or ${SHELLFLAGS},${SHELLFLAGS},-euo pipefail -c)

HERE := $(shell cd -P -- $(shell dirname -- $$0) && pwd -P)

.PHONY: all
all: start

.PHONY: has-command-%
has-command-%:
	@$(if $(shell command -v $* 2> /dev/null),,$(error The command $* does not exist in PATH))

.PHONY: is-defined-%
is-defined-%:
	@$(if $(value $*),,$(error The environment variable $* is undefined))

%.yaml: %.yaml.in is-defined-PODMAN_SSH_PUBKEY
	@cat $*.yaml.in                                                         \
	    | sed s/@PODMAN_SSH_PUBKEY@/"$(PODMAN_SSH_PUBKEY)"/                 \
	    > $*.yaml

.PHONY: create
create: has-command-multipass is-defined-PODMAN_VM podman-vm.yaml
	@if ! multipass list | grep -cq $(PODMAN_VM);                           \
	then                                                                    \
	    multipass launch                                                    \
	    -c 2                                                                \
	    -d 25G                                                              \
	    -m 4G                                                               \
	    --name $(PODMAN_VM)                                                 \
	    --cloud-init podman-vm.yaml                                         \
	    20.04;                                                              \
	    multipass mount $(HERE)/kibit-runner $(PODMAN_VM):/opt/kibit-runner;\
	fi
	@rm -f podman-vm.yaml

.PHONY: start
start: has-command-multipass is-defined-PODMAN_VM create
	@multipass start $(PODMAN_VM)

.PHONY: shell
shell: has-command-multipass is-defined-PODMAN_VM start
	@multipass shell $(PODMAN_VM)

.PHONY: status
status: has-command-multipass is-defined-PODMAN_VM
	@multipass info $(PODMAN_VM)

.PHONY: shutdown
shutdown: has-command-multipass is-defined-PODMAN_VM
	@multipass stop $(PODMAN_VM)

.PHONY: destroy
destroy: has-command-multipass is-defined-PODMAN_VM
	@multipass delete -p $(PODMAN_VM)

.PHONY: check-format
check-format: has-command-shfmt
	@shfmt -d -i 2 -bn podman-wrapper

.PHONY: format
format: has-command-shfmt
	@shfmt -w -i 2 -bn podman-wrapper

.PHONY: check-correct
check-correct: has-command-shellcheck
	@shellcheck podman-wrapper

.PHONY: lint
lint: check-format check-correct
