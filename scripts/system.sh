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


safe_symlink() {
    target="$1"
    link_path="$2"
    needs_link=0

    # Check if link_path exists
    if [ -e "$link_path" ] || [ -L "$link_path" ]; then
        # Check if it's a symlink
        if [ -L "$link_path" ]; then
            # Get the target of the symlink
            current_target=$(readlink "$link_path")

            # Check if it already points to the correct location
            if [ "$current_target" = "$target" ]; then
                echo "Symlink (${link_path}) already exists and points to the correct location"
            else
                # Symlink exists but points to wrong target - rename it
                mv "$link_path" "$link_path.bak"
                echo "Renamed existing symlink to $link_path.bak (was pointing to: $current_target)"
                needs_link=1
            fi
        else
            # It's a file or directory - rename it
            mv "$link_path" "$link_path.bak"
            echo "Renamed existing $link_path to $link_path.bak"
            needs_link=1
        fi
    else
        # Nothing exists at that path
        needs_link=1
    fi

    # Create the symlink if needed
    if [ "$needs_link" -eq 1 ]; then
        ln -s "$target" "$link_path"
        echo "Created symlink: $link_path -> $target"
    fi
}

do_install_darwin() {
	local install_dir
	info "[system] Install Darwin (MacOS) specific items..."
	if [ ! -d /opt/homebrew ]; then
	    info "[system][macos][homebrew] Install Homebrew"
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	fi
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
            safe_symlink $f ${HOME}/.paths.d/$(basename $f)
        done
    fi
    for f in $(pwd)/system/paths.d/*; do
        safe_symlink $f ${HOME}/.paths.d/$(basename $f)
    done

    info "[system][configure] Install \$HOME/etc dir"
    [ -d $HOME/etc ] || mkdir -p $HOME/etc
    if [ -d $(pwd)/system/home_etc.d ]; then
        for f in $(pwd)/system/home_etc.d/*; do
            safe_symlink $f ${HOME}/etc/$(basename $f)
        done
    fi

    info "[system][configure] Install \$HOME/lib dir"
    [ -d $HOME/lib ] || mkdir -p $HOME/lib
    for f in $( ls $(pwd)/system/home_lib.d 2>/dev/null ); do
        safe_symlink $f ${HOME}/lib/$(basename $f)
    done

    info "[system][configure] Install \$HOME/libexec dir"
    [ -d $HOME/libexec ] || mkdir -p $HOME/libexec
    for f in $( ls $(pwd)/system/home_libexec.d 2>/dev/null ); do
        safe_symlink $f ${HOME}/libexec/$(basename $f)
    done

    info "[system][configure] Install \$HOME/log dir"
    [ -d $HOME/log ] || mkdir -p $HOME/log
    for f in $(find $(pwd)/system/home_log.d -type f 2>/dev/null); do
        logdir=$(dirname "${HOME}/log/${f#*log.d/}")
        fname=$(basename $f)
        mkdir -p "${logdir}"
        safe_symlink $f "${logdir}/${fname}"
    done
    mkdir -p ${HOME}/log/bartib

    info "[system][configure] Shell (csh, sh, zsh & bash) startup files"
    if is_adi_host; then
        info "[system][configure][[t]csh] .user.cshrc"
        safe_symlink "$(pwd)/csh/cshrc.user" "${HOME}/.cshrc.user"
	fi

    info "[system][configure][terminfo] .terminfo"
    safe_symlink "$HOME/.dotfiles/terminfo" "$HOME/.terminfo"

    info "[system][configure][sh] .profile"
    safe_symlink "$(pwd)/sh/profile" "${HOME}/.profile"

    info "[system][configure][bash] .bash_profile"
    safe_symlink "$(pwd)/bash/bash_profile" "${HOME}/.bash_profile"

    info "[system][configure][bash] .bashrc"
    safe_symlink "$(pwd)/bash/bashrc" "${HOME}/.bashrc"

    info "[system][configure][zsh] .zprofile"
    safe_symlink "$(pwd)/zsh/zprofile" "${HOME}/.zprofile"

    info "[system][configure][zsh] .zshrc"
    safe_symlink "$(pwd)/zsh/zshrc" "${HOME}/.zshrc"

    info "[system][configure][common bash/zsh shell init] $HOME/.config/profile.d"
    safe_symlink "$(pwd)/config/profile.d" "${HOME}/.config/profile.d"

    info "[system][configure] Setup ADI modules"
    if type -t module >/dev/null 2>&1; then
        module unload git
    fi

    # Install modules links:
    if type -t module >/dev/null 2>&1; then
    	safe_symlink "$(pwd)/modules/adi_modules" "${HOME}/.adi_modules"
    	safe_symlink "$(pwd)/modules/ownpath" "${HOME}/.ownpath"
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
