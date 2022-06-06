# include test.mk

.DEFAULT_GOAL := all
.PHONY: git emacs

all: system git x11 terminal emacs ## Install and configure everything (default)
help: ## Display help
	@grep -hE '^[a-zA-Z_0-9%-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

system: system-install system-configure ## Install and configure
system-install: ## Install system packages
	@./scripts/system.sh install
system-configure: ## Configure system packages
	@./scripts/system.sh configure

git: ## Configure git
	@./scripts/git.sh configure

terminal: tmux bash csh zsh ohmyzsh ## Setup the terminal
tmux: ## Configure tmux
	@./scripts/tmux.sh configure
bash: ## Configure bash
	@./scripts/bash.sh configure
csh: ## Configure csh
	@./scripts/csh.sh configure
zsh: ## Configure zsh
	@./scripts/zsh.sh configure
ohmyzsh: ohmyzsh-install ohmyzsh-configure ## Install and configure Oh My Zsh
ohmyzsh-install: ## Install Oh My Zsh
	@./scripts/ohmyzsh.sh install
ohmyzsh-configure: ## Configure Oh My Zsh
	@./scripts/ohmyzsh.sh configure

emacs: ## Configure emacs
	@./scripts/emacs.sh configure

x11: ## Configure X11
	@./scripts/x11.sh configure
