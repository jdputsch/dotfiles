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
	info "[system] Pkgsrc"
	if [ ! -x /opt/pkg/bin/pkgin ]; then
		install_dir=/tmp/pkgsrc
		rm -rf ${install_dir} && mkdir -p ${install_dir}
		(
			cd ${install_dir}
			BOOTSTRAP_TAR="bootstrap-macos11-trunk-x86_64-20211207.tar.gz"
			BOOTSTRAP_SHA="07e323065708223bbac225d556b6aa5921711e0a"
			curl -O https://pkgsrc.joyent.com/packages/Darwin/bootstrap/${BOOTSTRAP_TAR}
			echo "${BOOTSTRAP_SHA}  ${BOOTSTRAP_TAR}" | shasum -c-
			sudo tar -zxpf ${BOOTSTRAP_TAR} -C /
			eval $(/usr/libexec/path_helper)
		)
		rm -rf ${install_dir}
	fi
	info "[system] git"
	[ -x /opt/pkg/bin/git ] || sudo pkgin -y install git
	info "[system] bash"
	[ -x /opt/pkg/bin/bash ] || sudo pkgin -y install bash
	info "[system] tmux"
	[ -x /opt/pkg/bin/tmux ] || sudo pkgin -y install tmux

	# Install pyenv
	if [ ! -d ${HOME}/.pyenv ]; then
	    (
			info "[system] pyenv"
			git clone --quiet https://github.com/pyenv/pyenv.git ~/.pyenv
			export PYENV_ROOT=${HOME}/.pyenv
			export PATH=${PYENV_ROOT}/bin:${PATH}
			eval "$(pyenv init -)"
			info "[system] pyenv-vitualenv"
			git clone --quiet https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv
			info "[system] pyenv-update"
			git clone --quiet https://github.com/pyenv/pyenv-update.git $(pyenv root)/plugins/pyenv-update
		)
	fi
}

do_install() {
	info "[system] Install"
	case ${OS} in
	    darwin) do_install_darwin ;;
		*) info "[system]     ... currently nothing to do" ;;
		esac
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
	(
	    cd "${install_dir}"
		curl -L -f -O https://github.com/IBM/plex/releases/download/v6.0.2/OpenType.zip
		unzip OpenType.zip
		cd OpenType
		find ./IBM-Plex-{Mono,Sans,Serif} -type f -name '*.otf' -exec cp -n "{}" "${FONTS_DIR}" \;
	) >/dev/null
	rm -rf "${install_dir}"

    info "[system][configure] Install Barlow fonts"
    install_dir="/tmp/barlow"
    rm -rf "${install_dir}" && mkdir -p "${install_dir}"
	(
	    cd "${install_dir}"
		curl -L -f -O https://github.com/jpt/barlow/archive/master.zip
		unzip master.zip
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
