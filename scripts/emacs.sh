#!/usr/bin/env bash

set -e

# shellcheck source=../scripts/util.sh
source "$(pwd)/scripts/util.sh"

EMACS_DIR="${HOME}/.emacs.d"

do_configure() {
	info "[emacs] Configure"

	info "[emacs][configure] Create configuration directory symlink"
	rm -rf "${HOME}/.emacs.d"
	ln -fs "$(pwd)/emacs/emacs.d" "${EMACS_DIR}"
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
