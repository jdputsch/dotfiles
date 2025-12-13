#!/bin/sh
#
# 99-zzz-tweaks.sh - Final System Tweaks and Adjustments
#
# Debug output can be enabled and will be written to $HOME/TWEAKS_DEBUG
# when that file exists.
#
# This script runs last in the profile.d initialization sequence (99-prefix)
# to apply final tweaks and adjustments that need to happen after all other
# configuration has been loaded. It handles platform-specific optimizations
# and system integration tasks.
#
# Key Responsibilities:
# - Platform-specific shell option adjustments
# - System integration for GUI environments (macOS launchd)
# - Background process optimizations
# - Final environment variable propagation
# - Shell prompt and terminal title customization
#
# Platform-Specific Tweaks:
#
# 1. Windows Subsystem for Linux (WSL):
#    - Disables BG_NICE option due to missing nice(2) system call
#    - Prevents background job scheduling issues in WSL environment
#
# 2. macOS (Darwin):
#    - Propagates environment variables to launchd for GUI applications
#    - Ensures PATH and MANPATH are available to graphical programs
#    - Only runs on interactive login shells to avoid unnecessary overhead
#
# Background Execution:
# The launchd integration runs in the background (&!) to avoid blocking
# the shell initialization process. This is important because launchctl
# operations can sometimes be slow and should not delay shell startup.
#
# Cross-Shell Compatibility:
# All checks use POSIX-compatible methods:
# - Interactive detection: Uses $- variable inspection
# - Portable syntax: Avoids shell-specific features
# - Standard conditionals: Uses [ ] instead of [[ ]] where possible
#
# Author: Jeff Putsch
# Part of: dotfiles configuration system
# Location: config/profile.d/99-zzz-tweaks.sh
#

# Check for debug mode
if [ -f "$HOME/TWEAKS_DEBUG" ]; then
    TWEAKS_DEBUG=1
    echo "99-zzz-tweaks.sh: Starting tweaks configuration" >> "$HOME/TWEAKS_DEBUG"
fi

# POSIX-compliant way to get hostname without domain
hostname_short() {
    hostname | cut -d. -f1
}

# Function to set terminal title
_set_term_title() {
    printf '\033]0;%s\007' "$1"
}

# Function to get current command being executed
get_current_command() {
    # Get last component of currently running command
    # shellcheck disable=SC2009
    ps -p $$ -o comm= | sed 's/^-//' | xargs basename 2>/dev/null || echo "shell"
}

# POSIX-compliant way to check if function exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Setup prompt and title updates
case $- in
    *i*)  # Only for interactive shells
        [ -n "$TWEAKS_DEBUG" ] && echo "99-zzz-tweaks.sh: Setting up interactive shell configuration" >> "$HOME/ENV_TWEAKS"
        # Source util.sh if is_adi_host is not available
        if ! command_exists is_adi_host; then
            # shellcheck disable=SC1091
            . "${HOME}/.dotfiles/scripts/util.sh"
        fi

        # Set initial prompt to hostname
        PS1="$(hostname_short)$ "

        # If we're on an ADI host, set up title updates
        if [ ${OS} = "darwin" ] || ( command_exists is_adi_host && is_adi_host ); then
            # Different handling for different shells while maintaining compatibility
            current_shell="${SHELL##*/}"
            [ -n "$TWEAKS_DEBUG" ] && echo "99-zzz-tweaks.sh: Configuring terminal title for $current_shell" >> "$HOME/ENV_TWEAKS"
            case "$current_shell" in
                bash)
                    # For bash, use PROMPT_COMMAND
                    pwd_short="${PWD#$HOME}"
                    pwd_short="~${pwd_short}"
                    PROMPT_COMMAND='pwd_short="${PWD#$HOME}"; pwd_short="~${pwd_short}"; if [ "$(get_current_command)" = "bash" ]; then _set_term_title "${pwd_short}"; else _set_term_title "$(ps -p $$ -o args= 2>/dev/null | sed "s/^-//")"; fi'
                    ;;
                zsh)
                    # For zsh, use precmd and preexec hooks, but only if not using Apple Terminal
                    # See: https://srstevenson.com/posts/zsh-terminal-title/
                    autoload -Uz add-zsh-hook
                    # unconditionally remove Apple's hook and use our own
                    add-zsh-hook -d precmd update_terminal_cwd
                    _precmd_title() {
                        if [[ -n "$SSH_CONNECTION" ]]; then
                          print -Pn "\e]0;%n@%m: %~\a"
                        else
                          print -Pn "\e]0;%~\a"
                        fi
                    }
                    _preexec_title() {
                        cmd="$1"
                        print -Pn "\e]0;${cmd}\a"
                    }
                    add-zsh-hook precmd _precmd_title
                    add-zsh-hook preexec _preexec_title
                    ;;
                *)
                    # For other shells, just set initial title to PWD
                    pwd_short="${PWD#$HOME}"
                    pwd_short="~${pwd_short}"
                    _set_term_title "${pwd_short}"
                    ;;
            esac
        fi
        ;;
esac

#
# WSL does not implement nice(2), therefore we turn off BG_NICE
#
if [ "${KERNEL}" = "*Microsoft*" ]; then
    if [ "${SHELL##*/}" = "zsh" ]; then
        unsetopt BG_NICE
        [ -n "$TWEAKS_DEBUG" ] && echo "99-zzz-tweaks.sh: Disabled BG_NICE for WSL" >> "$HOME/ENV_TWEAKS"
    fi
fi

# Execute code that does not affect the current session in the background.
# note: silent_background is setup in 20-functions.sh
[ -n "$TWEAKS_DEBUG" ] && echo "99-zzz-tweaks.sh: Starting background configuration" >> "$HOME/ENV_TWEAKS"
silent_background sh -c '
    # Set environment variables for launchd processes.
    # Only run on interactive shells on macOS to avoid unnecessary calls
    if [ "${OSTYPE#darwin}" != "${OSTYPE}" ]; then
        # Check if shell is interactive (portable method)
        case $- in
            *i*) _is_interactive=true ;;
            *) _is_interactive=false ;;
        esac

        # Only run launchctl if interactive
        if [ "$_is_interactive" = true ]; then
            export NODE_EXTRA_CA_CERTS=/Users/Shared/Netskope/netskope-cert-bundle.pem
            for env_var in PATH MANPATH NODE_EXTRA_CA_CERTS; do
                case $env_var in
                    PATH) launchctl setenv "$env_var" "$PATH" 2>/dev/null ;;
                    MANPATH) launchctl setenv "$env_var" "$MANPATH" 2>/dev/null ;;
                    NODE_EXTRA_CA_CERTS) launchctl setenv "$env_var" "$NODE_EXTRA_CA_CERTS" 2>/dev/null
                esac
            done
        fi

        unset _is_interactive
    fi
'

# Final debug output and cleanup
if [ -n "$TWEAKS_DEBUG" ]; then
    echo "99-zzz-tweaks.sh: Tweaks configuration completed" >> "$HOME/TWEAKS_DEBUG"
fi
