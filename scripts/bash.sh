#!/usr/bin/env bash

set -e

# shellcheck source=../scripts/util.sh
source "$(pwd)/scripts/util.sh"

do_configure() {
	info "[bash][configure] Create symlinks"
	ln -sf "$(pwd)/bash/bashenv" "${HOME}/.bashenv"
	ln -sf "$(pwd)/bash/bash_profile" "${HOME}/.bash_profile"
	ln -sf "$(pwd)/bash/bashrc" "${HOME}/.bashrc"
}

main() {
	command=$1
	case $command in
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
