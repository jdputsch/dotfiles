#!/usr/bin/env bash

set -e

# shellcheck source=../scripts/util.sh
source "$(pwd)/scripts/util.sh"

ZSH_CUSTOM="${HOME}/.dotfiles/zsh"

do_configure() {
	info "[zsh] Configure"
	info "[zsh] Startup Files configured in 'zsh'"

	# List of ZSH plugins to install. Plugin entry format:
	#   ["plugins/<name>"]="URL for git clone"
	declare -A plugins=(
	)
	for path in "${!plugins[@]}"; do
		if [[ ! -d "${ZSH_CUSTOM}/$path" ]]; then
			git clone --quiet "${plugins[$path]}" "${ZSH_CUSTOM}/$path"
		fi
	done

	info "[zsh][configure] Create symlinks"
	ln -sf "$(pwd)/zsh/zlogin" "${HOME}/.zlogin"
	ln -sf "$(pwd)/zsh/zlogout" "${HOME}/.zlogout"
	ln -sf "$(pwd)/zsh/zprofile" "${HOME}/.zprofile"
	ln -sf "$(pwd)/zsh/zshenv" "${HOME}/.zshenv"
	ln -sf "$(pwd)/zsh/zshrc" "${HOME}/.zshrc"

}

main() {
	command=$1
	case $command in
	"configure")
		shift
		type -P zsh >/dev/null 2>&1 && do_configure "$@" || info "[zsh] Skipping configure - zsh not available"
		;;
	*)
		error "$(basename "$0"): '$command' is not a valid command"
		;;
	esac
}

main "$@"
