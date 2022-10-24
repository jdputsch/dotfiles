# include test.mk

.DEFAULT_GOAL := all
.PHONY: git emacs

OSTYPE := $(shell uname -s | tr '[A-Z]' '[a-z]')

ifeq ($(OSTYPE),darwin)
BASH=/opt/pkg/bin/bash
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

terminal: tmux bash csh zsh ohmyzsh ## Setup the terminal
tmux: FORCE ## Configure tmux
	@./scripts/tmux.sh configure
bash: FORCE ## Configure bash
	@./scripts/bash.sh configure
csh: FORCE ## Configure csh
	@./scripts/csh.sh configure
zsh: FORCE ## Configure zsh
	@./scripts/zsh.sh configure
ohmyzsh: ohmyzsh-install ohmyzsh-configure ## Install and configure Oh My Zsh
ohmyzsh-install: system-install FORCE ## Install Oh My Zsh
	@$(BASH) ./scripts/ohmyzsh.sh install
ohmyzsh-configure: FORCE ## Configure Oh My Zsh
	@$(BASH) ./scripts/ohmyzsh.sh configure

emacs: FORCE ## Configure emacs
	@./scripts/emacs.sh configure

x11: FORCE ## Configure X11
	@./scripts/x11.sh configure

FORCE:
