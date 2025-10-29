#!/bin/sh
#
# 30-history.sh - Shell History Configuration
#
# This script configures history settings for various shells (sh, bash, zsh).
# It aims to provide consistent history behavior across different shells
# while respecting each shell's capabilities and limitations.
#
# Key Features:
# - Sets history size to 1000 commands
# - Uses separate history files per shell type
# - Applies settings only for interactive shells
#
# Shell-Specific Behaviors:
# - sh: Limited history support (implementation dependent)
# - bash: Full history support with size limits (.bash_history)
# - zsh: Full history support with size limits (.zsh_history)
#
# Environment Variables:
# - HISTSIZE: Number of commands to keep in memory
# - HISTFILE: Location of history file
# - SAVEHIST/HISTFILESIZE: Number of commands to save to file
#
# Author: Jeff Putsch
# Part of: dotfiles configuration system
# Location: config/profile.d/30-history.sh
#

# Only configure history for interactive shells
case $- in
    *i*)
        # Set history size to 1000 commands for all shells
        HISTSIZE=1000

        # Shell-specific configurations
        case "${SHELL##*/}" in
            bash)
                # Set bash-specific history file and size
                HISTFILE="${HOME}/.bash_history"
                HISTFILESIZE=1000
                export HISTTIMEFORMAT="%FT%T%z %s "
                # Append to history rather than overwrite
                shopt -s histappend 2>/dev/null
                ;;
            zsh)
                # Set zsh-specific history file and size
                HISTFILE="${HOME}/.zsh_history"
                SAVEHIST=1000
                # zsh-specific history options
                setopt APPEND_HISTORY 2>/dev/null
                setopt HIST_IGNORE_ALL_DUPS 2>/dev/null
                setopt HIST_REDUCE_BLANKS 2>/dev/null
                setopt EXTENDED_HISTORY 2>/dev/null
                ;;
            *)
                # Default history file for other shells
                HISTFILE="${HOME}/.sh_history"
                ;;
        esac

        # Ensure history file exists with proper permissions
        [ ! -f "${HISTFILE}" ] && touch "${HISTFILE}" 2>/dev/null
        [ -f "${HISTFILE}" ] && chmod 600 "${HISTFILE}" 2>/dev/null

        # Export history variables
        export HISTFILE HISTSIZE HISTFILESIZE
        ;;
esac
