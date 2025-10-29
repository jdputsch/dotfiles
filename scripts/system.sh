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

do_install_darwin() {
	local install_dir
	info "[system] Install Darwin (MacOS) specific items..."
	[ -x /opt/local/bin/git ] || sudo port install git
	info "[system] bash"
	[ -x /opt/local/bin/bash ] || sudo port install bash
	info "[system] tmux"
	[ -x /opt/local/bin/tmux ] || sudo port install tmux
}

do_install() {
	info "[system] Install"
	case ${OS} in
	    darwin) echo do_install_darwin ;;
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

    for dir in .config bin etc lib libexec log src tmp; do
        info "[system][configure][directories] User $dir directory"
        mkdir -p "${HOME}/${dir}"
        chmod 0755 "${HOME}/${dir}"
    done

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
    if [ -d $(pwd)/system/home_etc.d ]; then
        for f in $(pwd)/system/home_etc.d/*; do
            ln -sf $f ${HOME}/etc/$(basename $f)
        done
    fi

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

    info "[system][configure] Install \$HOME/log dir"
    [ -d $HOME/log ] || mkdir -p $HOME/log
    for f in $(find $(pwd)/system/home_log.d -type f 2>/dev/null); do
        logdir=$(dirname "${HOME}/log/${f#*log.d/}")
        fname=$(basename $f)
        mkdir -p "${logdir}"
        ln -sf $f "${logdir}/${fname}"
    done

    info "[system][configure] Shell (csh, sh, zsh & bash) startup files"
    info "[system][configure][[t]csh] .user.cshrc"
    if is_adi_host; then
		ln -sf "$(pwd)/csh/cshrc.user" "${HOME}/.cshrc.user"
	fi
    info "[system][configure][sh] .profile"
    ln -sf "$(pwd)/sh/profile" "${HOME}/.profile"
    info "[system][configure][bash] .bash_profile"
    ln -sf "$(pwd)/bash/bash_profile" "${HOME}/.bash_profile"
    info "[system][configure][bash] .bashrc"
    ln -sf "$(pwd)/bash/bashrc" "${HOME}/.bashrc"
    info "[system][configure][zsh] .zprofile"
    ln -sf "$(pwd)/zsh/zprofile" "${HOME}/.zprofile"
    info "[system][configure][zsh] .zshrc"
    ln -sf "$(pwd)/zsh/zshrc" "${HOME}/.zshrc"
    info "[system][configure][common bash/zsh shell init] $HOME/.config/profile.d"
    if [ -e ${HOME}/.config/profile.d ] && [ ! -h ${HOME}/.config/profile.d ]; then
        rm -rf ${HOME}/.config/profile.d
    elif [ ! -e ${HOME}/.config/profile.d ]; then
        ln -sf "$(pwd)/config/profile.d" "${HOME}/.config/profile.d"
    fi

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
