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
    local install_dir
	info "[fonts] Install"
    ( hostname | egrep -v -q '(engitar.analog.com|eng.analogfed.com)' && do_fonts ) || info "[fonts][configure](fonts) - Skipping in ITAR pods"

    info "[fonts][directories] User Fonts"
    mkdir -p "${FONTS_DIR}"
    chmod 0755 "${FONTS_DIR}"

    info "[fonts] Install IBM Plex fonts"
    install_dir="/tmp/ibm-plex"
    rm -rf "${install_dir}" && mkdir -p "${install_dir}"
    (
        cd "${install_dir}"
        curl -L -f -O https://github.com/IBM/plex/releases/download/v6.0.2/OpenType.zip
        unzip OpenType.zip
        cd OpenType
        find ./IBM-Plex-{Mono,Sans,Serif} -type f -name '*.otf' -exec cp -n "{}" "${FONTS_DIR}" \;
    ) >/dev/null
    rm -rf "${install_dir}"

    info "[fonts] Install Barlow fonts"
    install_dir="/tmp/barlow"
    rm -rf "${install_dir}" && mkdir -p "${install_dir}"
    (
        cd "${install_dir}"
        curl -L -f -O https://github.com/jpt/barlow/archive/master.zip
        unzip master.zip
        find . -type f -name '*.otf' -exec cp -n "{}" "${FONTS_DIR}" \;
    ) >/dev/null
    rm -rf "${install_dir}"

    info "[fonts] Install FontAwesome fonts"
    install_dir="/tmp/font_awesome"
    rm -rf "${install_dir}" && mkdir -p "${install_dir}"
    (
        cd "${install_dir}"
        curl -s -L -f -O https://use.fontawesome.com/releases/v6.1.1/fontawesome-free-6.1.1-desktop.zip
        unzip fontawesome-free-6.1.1-desktop.zip
        find . -type f -name '*.otf' -exec cp -n "{}" "${FONTS_DIR}" \;
    ) >/dev/null
    rm -rf "${install_dir}"

    info "[fonts] Install JetBrains Mono fonts"
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
