#!/usr/bin/env bash

set -e

# shellcheck source=../scripts/util.sh
source "$(pwd)/scripts/util.sh"

ZSH="${HOME}/.oh-my-zsh"
ZSH_CUSTOM="${ZSH}/custom"

do_install() {
	if [[ -d "${ZSH}" ]]; then
		info "[ohmyzsh] Already installed"
		return
	fi

	info "[ohmyzsh] Install"
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended
}

do_configure() {
	info "[ohmyzsh] Configure"
	info "[ohmyzsh][configure] Download plugins"
	# plugin entry format:
	#   ["plugins/<name>"]="URL for git clone"
	declare -A plugins=(
	)
	for path in "${!plugins[@]}"; do
		if [[ ! -d "${ZSH_CUSTOM}/$path" ]]; then
			git clone --quiet "${plugins[$path]}" "${ZSH_CUSTOM}/$path"
		fi
	done

	info "[ohmyzsh][configure] Create symlinks"
	ln -sf "$(pwd)/zsh/zlogin" "${HOME}/.zlogin"
	ln -sf "$(pwd)/zsh/zlogout" "${HOME}/.zlogout"
	ln -sf "$(pwd)/zsh/zprofile" "${HOME}/.zprofile"
	ln -sf "$(pwd)/zsh/zshenv" "${HOME}/.zshenv"
	ln -sf "$(pwd)/zsh/zshrc" "${HOME}/.zshrc"
	info "[ohmyzsh][configure] Make custom dirs"
	for d in $(find $(pwd)/zsh/oh-my-zsh/custom -type d); do
		mkdir -p "${ZSH_CUSTOM}/${d#*oh-my-zsh/custom}"
	done
	info "[ohmyzsh][configure] Install customizations"
	for f in $(find $(pwd)/zsh/oh-my-zsh/custom -type f); do
	    ln -sf "${f}" "${ZSH_CUSTOM}/${f#*oh-my-zsh/custom/}"
	done
}

main() {
	command=$1
	case $command in
	"install")
		shift
		type -P zsh >/dev/null 2>&1 && do_install "$@" || info "[ohmyzsh] Skipping install - zsh not available."
		;;
	"configure")
		shift
		type -P zsh >/dev/null 2>&1 && do_configure "$@" || info "[ohmyzsh] Skipping configure - zsh not available."
		;;
	*)
		error "$(basename "$0"): '$command' is not a valid command"
		;;
	esac
}

main "$@"
