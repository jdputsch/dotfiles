# include test.mk

.DEFAULT_GOAL := all
.PHONY: git emacs

OSTYPE := $(shell uname -s | tr '[A-Z]' '[a-z]')

ifeq ($(OSTYPE),darwin)
BASH=/opt/local/bin/bash
else
BASH=/usr/bin/bash
endif

all: system git x11 terminal emacs ## Install and configure everything (default)
help: ## Display help
	@grep -hE '^[a-zA-Z_0-9%-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

system: system-install system-configure ## Install and configure
system-install: FORCE ## Install system packages
	@./scripts/system.sh install
system-configure: FORCE ## Configure system packages
	@./scripts/system.sh configure

git: FORCE ## Configure git
	@./scripts/git.sh configure

terminal: tmux ## Setup the terminal
tmux: FORCE ## Configure tmux
	@./scripts/tmux.sh configure

emacs: FORCE ## Configure emacs
	@./scripts/emacs.sh configure

x11: FORCE ## Configure X11
	@./scripts/x11.sh configure
	
fonts: FORCE ## Install fonts
	@./scripts/fonts.sh configure

FORCE:
