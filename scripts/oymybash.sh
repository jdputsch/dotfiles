#!/usr/bin/env bash

set -e

# shellcheck source=../scripts/util.sh
source "$(pwd)/scripts/util.sh"

BASH="${HOME}/.oh-my-bash"
BASH_CUSTOM="${BASH}/custom"

do_install() {
	if [[ -d "${BASH}" ]]; then
		info "[ohmybash] Already installed"
		return
	fi

	info "[ohmybash] Install"
	bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
}

do_configure() {
	info "[ohmybash] Configure"
	info "[ohmybash][configure] Download plugins"
	# plugin entry format:
	#   ["plugins/<name>"]="URL for git clone"
	declare -A plugins=(
	)
	for path in "${!plugins[@]}"; do
		if [[ ! -d "${BASH_CUSTOM}/$path" ]]; then
			git clone --quiet "${plugins[$path]}" "${BASH_CUSTOM}/$path"
		fi
	done

	info "[ohmybash][configure] Create symlinks"
	    ln -sf "$(pwd)/bash/bashenv" "${HOME}/.bashenv"
        ln -sf "$(pwd)/bash/bash_profile" "${HOME}/.bash_profile"
        ln -sf "$(pwd)/bash/bashrc" "${HOME}/.bashrc"
	info "[ohmybash][configure] Make custom dirs"
	info "[ohmybash][configure] Install customizations"
	mkdir -p ${BASH_CUSTOM}/lib
	for f in $(find $(pwd)/bash/oh-my-bash/custom -type f); do
	    ln -sf "${f}" "${BASH_CUSTOM}/${f#*oh-my-bash/custom/}"
	done
}

main() {
	command=$1
	case $command in
	"install")
		shift
		do_install "$@"
		;;
	"configure")
		shift
		do_configure "$@"
		;;
	*)
		error "$(basename "$0"): '$command' is not a valid command"
		;;
	esac
}

main "$@"
