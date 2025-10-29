#!/bin/sh
#
# 05-env.sh - Core Environment Variables Configuration
#
# This script sets up essential environment variables that are needed early
# in the shell initialization process. It runs after platform detection
# (00-platform.sh) but before path configuration (10-path.sh) to ensure
# these variables are available for use by subsequent configuration files.
#
# Key Categories of Environment Variables:
#
# 1. XDG Base Directory Specification:
#    - Implements the XDG standard for organizing user files
#    - Defines locations for config, data, and cache directories
#    - Used by modern applications for consistent file organization
#
# 2. Development Tool Locations:
#    - Rust (Cargo/Rustup): Follows XDG standard placement
#    - Go (GOPATH): Sets workspace location following XDG
#    - Python (PIP): Configures virtualenv requirements
#
# 3. System Integration:
#    - X11 environment settings for GUI applications
#    - Shell detection and configuration for various platforms
#    - Locale settings with fallback logic
#
# 4. Platform-Specific Configuration:
#    - macOS: Disables shell sessions, configures Perforce
#    - Linux: WSL detection and shell path correction
#    - Universal: Cross-platform environment standardization
#
# 5. Application-Specific Settings:
#    - Perforce (P4): Version control system configuration
#    - Bartib: Time tracking data file location
#    - p4merge: Merge tool function definition
#
# Environment Variables Set:
# - XENVIRONMENT: X11 resources file location
# - XDG_CONFIG_HOME: User configuration directory
# - XDG_DATA_HOME: User data directory
# - XDG_CACHE_HOME: User cache directory
# - CARGO_HOME: Rust package manager home
# - RUSTUP_HOME: Rust toolchain manager home
# - GOPATH: Go workspace directory
# - SHELL: System shell executable path
# - SHELL_SESSIONS_DISABLE: Disables macOS shell sessions
# - LANG: System locale setting
# - P4CONFIG, P4PORT, P4USER: Perforce configuration
# - PIP_REQUIRE_VIRTUALENV: Python package manager behavior
# - BARTIB_FILE: Time tracking data file location
#
# Dependencies:
# - OS variable from platform detection (00-platform.sh)
# - HOST variable for hostname-specific configuration
# - Standard system utilities: locale, readlink, etc.
#
# Design Philosophy:
# This file prioritizes setting environment variables that:
# - Follow modern standards (XDG Base Directory Specification)
# - Are needed by multiple applications or subsequent scripts
# - Require early initialization before PATH manipulation
# - Provide consistent behavior across different platforms
#
# Author: Jeff Putsch
# Part of: dotfiles configuration system
# Location: config/profile.d/05-env.sh
#

# Set environment variables early in the sequence of init files, we
# may rely on them in later init files (e.g. setting PATH)

if [ -f "$HOME"/DOTFILE_DEBUG ]; then
    echo "DEBUG: Init file: $HOME/.config/profile.d/05-env.sh" >&2
fi

# Basic X11 environment settings
export XENVIRONMENT="${HOME}/.Xdefaults"

# Setup XDG environment variables
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_CACHE_HOME="${HOME}/.cache"

# Setup Rust CARGO and RUSTUP locations
export CARGO_HOME="${XDG_DATA_HOME}/cargo"
export RUSTUP_HOME="${XDG_DATA_HOME}/rustup"

# Setup Go locations
export GOPATH="${XDG_DATA_HOME}/go"
if [ "${OS}" = linux ]; then
    :
fi

# Places we may need to set the SHELL environment variable
if [ "${OS}" = linux ]; then
    if grep -q Microsoft /proc/version 2>/dev/null; then
        export SHELL=/usr/bin/zsh
    elif [ -z "${SHELL}" ]; then
        # Use ps to get shell path in a POSIX way
        export SHELL=$(ps -p "$$" -o comm= | sed 's/^-//')
    fi
fi

# Do not use Apple specific shell sessions
export SHELL_SESSIONS_DISABLE=1

# Language
if [ -z "${LANG}" ]; then
    # Use grep -E instead of egrep and handle the output more carefully
    def_locale=$(locale -a | grep -E 'en.*US.*UTF-8' | head -n 1)
    if [ -n "${def_locale}" ]; then
        export LANG="${def_locale}"
    else
        export LANG=C
    fi
fi

# Set P4 environment variables based on the platform & host
if [ "${OS}" = darwin ] && [ "${HOST}" = "JPUTSCH-M01"* ]; then
    export P4CONFIG=.p4config
    export P4PORT=p4e.adsiv.analog.com:1666
    export P4USER=jputsch

    if [ -x /Applications/p4merge.app/Contents/MacOS/p4merge ]; then
        p4merge() {
            /Applications/p4merge.app/Contents/MacOS/p4merge "$@"
        }
    fi
fi

# PIP behavior, for python
# require virtualenv for using pip
export PIP_REQUIRE_VIRTUALENV=true

# Bartib (time tracker) data file location:
export BARTIB_FILE="${HOME}/log/bartib/activity.bartib"
