#!/usr/bin/env bash

set -e

if [ -z "$FAST_MODULES" ]; then
	FAST_MODULES=true
	export FAST_MODULES
fi

if [ -f /usr/cadtools/bin/modules.dir/Shrc ]; then
    . /usr/cadtools/bin/modules.dir/Shrc ]
fi



# shellcheck source=../scripts/identify_platform.sh
source "$(pwd)/scripts/identify_platform.sh"

# shellcheck source=../scripts/util.sh
source "$(pwd)/scripts/util.sh"

case ${OS} in
    darwin) FONTS_DIR="${HOME}/Library/Fonts" ;;
    linux) FONTS_DIR="$HOME/.local/share/fonts" ;;
    *) FONTS_DIR="$HOME/.local/share/fonts" ;;
esac


do_install() {
	info "[system] Install"
	info "[system]     ... currently nothing to do"
}

do_configure() {
    local install_dir

	if type -t module >/dev/null 2>&1; then
	    module load git
	fi
	set +x

    info "[system] Configure"
    info "[system][configure][directories] User Fonts"
	mkdir -p "${FONTS_DIR}"
	chmod 0755 "${FONTS_DIR}"

    info "[system][configure][directories] User binaries directory"
	mkdir -p "${HOME}/bin"
	chmod 0755 "${HOME}/bin"

    info "[system][configure] Install IBM Plex fonts"
    install_dir="/tmp/ibm-plex"
    rm -rf "${install_dir}" && mkdir -p "${install_dir}"
	git clone --quiet --sparse "https://github.com/IBM/plex.git" "${install_dir}"
	(
	    cd "${install_dir}"
		git sparse-checkout add IBM-Plex-Mono/fonts/complete/otf
		git sparse-checkout add IBM-Plex-Sans/fonts/complete/otf
		git sparse-checkout add IBM-Plex-Serif/fonts/complete/otf
		find . -type f -name '*.otf' -exec cp -n "{}" "${FONTS_DIR}" \;
	) >/dev/null
	rm -rf "${install_dir}"

    info "[system][configure] Install Barlow fonts"
    install_dir="/tmp/barlow"
    rm -rf "${install_dir}" && mkdir -p "${install_dir}"
	git clone --quiet --sparse "https://github.com/jpt/barlow.git" "${install_dir}"
	(
	    cd "${install_dir}"
		git sparse-checkout add fonts/otf
		find . -type f -name '*.otf' -exec cp -n "{}" "${FONTS_DIR}" \;
	) >/dev/null
	rm -rf "${install_dir}"

    info "[system][configure] Install FontAwesome fonts"
    install_dir="/tmp/font_awesome"
    rm -rf "${install_dir}" && mkdir -p "${install_dir}"
	(
	    cd "${install_dir}"
		curl -s -L -f -O https://use.fontawesome.com/releases/v6.1.1/fontawesome-free-6.1.1-desktop.zip
		unzip fontawesome-free-6.1.1-desktop.zip
		find . -type f -name '*.otf' -exec cp -n "{}" "${FONTS_DIR}" \;
	) >/dev/null
	rm -rf "${install_dir}"

    info "[system][configure] Install JetBrains Mono fonts"
    install_dir="/tmp/jb_mono"
    rm -rf "${install_dir}" && mkdir -p "${install_dir}"
	(
	    cd "${install_dir}"
		curl -s -L -f -O https://download.jetbrains.com/fonts/JetBrainsMono-2.242.zip
		unzip JetBrainsMono-2.242.zip
		find . -type f -name '*.ttf' -exec cp -n "{}" "${FONTS_DIR}" \;
	) >/dev/null
	rm -rf "${install_dir}"

	if [ "${OS}" == linux ]; then
    	fc-cache -f
	fi

	if type -t module >/dev/null 2>&1; then
	    module unload git
	fi

	# Install modules links:
	if type -t module >/dev/null 2>&1; then
		ln -sf "$(pwd)/modules/adi_modules" "${HOME}/.adi_modules"
		ln -sf "$(pwd)/modules/ownpath" "${HOME}/.ownpath"
	fi
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
