#!/usr/bin/env bash

set -e

# shellcheck source=../scripts/util.sh
source "$(pwd)/scripts/util.sh"

do_configure() {
	info "[zsh] Configure"
	info "[zsh] Startup Files configured in 'ohmyzsh'"
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
