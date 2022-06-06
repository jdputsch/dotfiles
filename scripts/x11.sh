#!/usr/bin/env bash

set -e

# shellcheck source=../scripts/util.sh
source "$(pwd)/scripts/util.sh"

do_configure() {
	info "[x11] Configure"
	info "[x11][configure] Create X11 config file symlinks"
	ln -fs "$(pwd)/X11/Xdefaults" "${HOME}/.Xdefaults"
	ln -fs "$(pwd)/X11/Xresources" "${HOME}/.Xresources"
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
