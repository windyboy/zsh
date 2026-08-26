# Makefile for the ZSH configuration project.
# Thin wrappers around ./test.sh, install.sh, and update.sh.

.DEFAULT_GOAL := help
SHELL := /bin/bash

.PHONY: help test all syntax environment modules installer update install lint shellcheck

help: ## Show available targets
	@grep -hE '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

test: ## Run full test suite (./test.sh)
	./test.sh

all: test ## Alias for full test suite
	./test.sh update

syntax: ## Syntax checks only
	./test.sh syntax

environment: ## Environment tests only
	./test.sh environment

modules: ## Module tests only
	./test.sh modules

installer: ## Installer tests only
	./test.sh installer

update: ## Run update.sh (pull plugins, refresh config)
	./update.sh

install: ## Run installer against this checkout
	./install.sh

lint: shellcheck syntax ## ShellCheck + zsh syntax checks

shellcheck: ## ShellCheck on supported shell scripts
	shellcheck install.sh test.sh update.sh scripts/lib/*.sh env/*.sh || true

zsh-syntax: ## zsh -n over every .zsh file
	@set -e; for f in zshrc zshenv modules/*.zsh themes/*.zsh; do zsh -n "$$f"; done
