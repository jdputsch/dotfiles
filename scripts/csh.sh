#!/usr/bin/env bash

set -e

# shellcheck source=../scripts/util.sh
source "$(pwd)/scripts/util.sh"

do_configure() {
	info "[csh][configure] Create symlinks"
	if is_adi_host; then
		ln -sf "$(pwd)/csh/cshrc.user" "${HOME}/.cshrc.user"
	fi
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
