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

do_install_darwin() {
	local install_dir
	info "[system] Install Darwin (MacOS) specific items..."
	info "[system] MacPorts"
	if [ ! -x /opt/local/bin/port ]; then
		install_dir=/tmp/ports
		rm -rf ${install_dir} && mkdir -p ${install_dir}
		(
		    cd ${install_dir}
		    os_version=$(sw_vers --productVersion)
		    if [ $os_version = 14.* ]; then
			    pkg__url=https://github.com/macports/macports-base/releases/download/v2.9.1/MacPorts-2.9.1-14-Sonoma.pkg
			elif [ $os_version = 13.* ]; then
			    pkg_url=https://github.com/macports/macports-base/releases/download/v2.9.1/MacPorts-2.9.1-13-Ventura.pkg
			elif [ $os_version = 12.* ]; then
			    pkg_url=https://github.com/macports/macports-base/releases/download/v2.9.1/MacPorts-2.9.1-12-Monterey.pkg
			fi
			pgk_file=$(basename $pkg_url)
		    curl -O $pkg_url
		    sudo installer -pkg $pkg_file -target /
		)
		rm -rf ${install_dir}
	fi
	info "[system] git"
	[ -x /opt/local/bin/git ] || sudo port install git
	info "[system] bash"
	[ -x /opt/local/bin/bash ] || sudo port install bash
	info "[system] tmux"
	[ -x /opt/local/bin/tmux ] || sudo port install tmux
}

do_install() {
	info "[system] Install"
	case ${OS} in
	    darwin) do_install_darwin ;;
	    *) info "[system]     ... currently nothing to do" ;;
	esac
}

do_fonts() {
    local install_dir

    info "[system][configure][directories] User Fonts"
    mkdir -p "${FONTS_DIR}"
    chmod 0755 "${FONTS_DIR}"

    info "[system][configure][fonts] Install IBM Plex fonts"
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

    info "[system][configure][fonts] Install Barlow fonts"
    install_dir="/tmp/barlow"
    rm -rf "${install_dir}" && mkdir -p "${install_dir}"
    (
        cd "${install_dir}"
        curl -L -f -O https://github.com/jpt/barlow/archive/master.zip
        unzip master.zip
        find . -type f -name '*.otf' -exec cp -n "{}" "${FONTS_DIR}" \;
    ) >/dev/null
    rm -rf "${install_dir}"

    info "[system][configure][fonts] Install FontAwesome fonts"
    install_dir="/tmp/font_awesome"
    rm -rf "${install_dir}" && mkdir -p "${install_dir}"
    (
        cd "${install_dir}"
        curl -s -L -f -O https://use.fontawesome.com/releases/v6.1.1/fontawesome-free-6.1.1-desktop.zip
        unzip fontawesome-free-6.1.1-desktop.zip
        find . -type f -name '*.otf' -exec cp -n "{}" "${FONTS_DIR}" \;
    ) >/dev/null
    rm -rf "${install_dir}"

    info "[system][configure][fonts] Install JetBrains Mono fonts"
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

do_configure() {
    local install_dir

    if type -t module >/dev/null 2>&1; then
        module load git
    fi
    set +x

    info "[system] Configure"

    info "[system][configure][directories] User binaries directory"
    mkdir -p "${HOME}/bin"
    chmod 0755 "${HOME}/bin"

    ( hostname | grep -v -q engitar.analog.com && do_fonts ) || info "[system][configure](fonts) - Skipping in ITAR pods"

    info "[system][configure] Install \$HOME/.paths.d dir"
    if [[ -L $HOME/.paths.d ]] \
        || ( [[ -e $HOME/.paths.d ]] && ! [[ -d $HOME/.paths.d ]] ); then
        rm -f $HOME/.paths.d
    fi
    [[ -d $HOME/.paths.d ]] || mkdir -p $HOME/.paths.d
    if is_maxim_host; then
        for f in $(pwd)/system/paths-maxim.d/*; do
            ln -sf $f ${HOME}/.paths.d/$(basename $f)
        done
    fi
    for f in $(pwd)/system/paths.d/*; do
        ln -sf $f ${HOME}/.paths.d/$(basename $f)
    done

    info "[system][configure] Install \$HOME/etc dir"
    [ -d $HOME/etc ] || mkdir -p $HOME/etc
    for f in $(pwd)/system/home_etc.d/*; do
        ln -sf $f ${HOME}/etc/$(basename $f)
    done

    info "[system][configure] Install \$HOME/lib dir"
    [ -d $HOME/lib ] || mkdir -p $HOME/lib
    for f in $( ls $(pwd)/system/home_lib.d 2>/dev/null ); do
        ln -sf $f ${HOME}/lib/$(basename $f)
    done

    info "[system][configure] Install \$HOME/libexec dir"
    [ -d $HOME/libexec ] || mkdir -p $HOME/libexec
    for f in $( ls $(pwd)/system/home_libexec.d 2>/dev/null ); do
        ln -sf $f ${HOME}/libexec/$(basename $f)
    done

    info "[system][configure] Setup ADI modules"
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
