#!/usr/bin/env bash

set -e

# shellcheck source=../scripts/util.sh
source "$(pwd)/scripts/util.sh"

if is_adi_host; then
    GIT_CONFIG="$(pwd)/git/gitconfig.adi"
elif is_maxim_host; then
	GIT_CONFIG="$(pwd)/git/gitconfig.maxim"
else
	GIT_CONFIG="$(pwd)/git/gitconfig"
fi

do_configure() {
	info "[git] Configure"
	info "[git][configure] Create config file symlink"
	ln -fs "${GIT_CONFIG}" "${HOME}/.gitconfig"

	# info "[git][configure] Create a commit-template file"
	# touch "$(pwd)/git/commit-template"
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
