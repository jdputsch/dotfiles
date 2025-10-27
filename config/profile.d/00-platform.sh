
#!/bin/sh
#
# 00-platform.sh - Platform Detection and Core Directory Configuration
#
# This script is the foundational configuration file that sets up essential
# environment variables for the dotfiles system. It runs first (00-prefix)
# to establish core paths and platform identification that other scripts depend on.
#
# Key Responsibilities:
# - Cross-shell compatible directory path detection and configuration
# - Platform identification and standardization
# - Core environment variable setup for the dotfiles ecosystem
#
# Environment Variables Set:
# - CONFIG_PROFILE_D_DIR: Absolute path to the config/profile.d directory
# - DOTFILES_DIR: Absolute path to the root dotfiles directory
# - PLATFORM_ID: Standardized platform identifier (e.g., "darwin-14-arm64")
#
# Platform Detection:
# The PLATFORM_ID variable combines:
# - DistroBasedOn: Base distribution/OS (darwin, redhat, debian, etc.)
# - MAJOR_REV: Major version number of the OS
# - MACH: Machine architecture (x86_64, arm64, etc.)
# Format: "${DistroBasedOn}-${MAJOR_REV}-${MACH}"
#
# Cross-Shell Compatibility:
# This script works across sh, bash, and zsh by detecting the shell type
# and using appropriate methods for path resolution:
# - Zsh: Uses parameter expansion with :A modifier for symlink resolution
# - Bash: Uses BASH_SOURCE[0] with realpath for accurate path detection
# - POSIX sh: Falls back to $0 with realpath and fallback mechanisms
#
# Path Resolution:
# All paths are resolved to their canonical form using realpath to handle
# symlinks correctly. This is especially important when ~/.config/profile.d
# is a symlink to ~/.dotfiles/config/profile.d
#
# Dependencies:
# - scripts/identify_platform.sh: Platform detection script
# - realpath: Command for resolving symbolic links (standard on modern systems)
#
# Usage:
# This file is typically sourced by shell initialization files and should
# be loaded before other profile.d scripts due to its 00- prefix.
#
# Author: Jeff Putsch
# Part of: dotfiles configuration system
# Location: config/profile.d/00-platform.sh
#

# Set the location of config profile.d directory (portable across sh/bash/zsh):
if [ -n "$ZSH_VERSION" ]; then
    # Zsh-specific method using parameter expansion
    export CONFIG_PROFILE_D_DIR=${${(%):-%N}:A:h}
elif [ -n "$BASH_VERSION" ]; then
    # Bash-specific method using BASH_SOURCE
    export CONFIG_PROFILE_D_DIR="$(realpath $(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd))"
else
    # POSIX sh fallback - use $0 but may not work with sourced files
    # This assumes the script is being sourced from the correct directory
    export CONFIG_PROFILE_D_DIR="$(realpath $(cd "$(dirname "$0")" 2>/dev/null && pwd))"
    # If that fails, try to determine from PWD if we're in the right place
    if [ -z "$CONFIG_PROFILE_D_DIR" ] || [ ! -d "$CONFIG_PROFILE_D_DIR" ]; then
        # Fallback: assume we're being sourced and use a known path
        if [ -d "${HOME}/.dotfiles/config/profile.d" ]; then
            export CONFIG_PROFILE_D_DIR="${HOME}/.dotfiles/config/profile.d"
        fi
    fi
fi

# Set DOTFILES_DIR to be the grandparent directory of CONFIG_PROFILE_D_DIR
# This works by going up two levels: profile.d -> config -> dotfiles
if [ -n "$CONFIG_PROFILE_D_DIR" ]; then
    export DOTFILES_DIR="$(dirname "$(dirname "$CONFIG_PROFILE_D_DIR")")"
fi

export PLATFORM_ID=""
if [ -z "${DistroBasedOn}" ] && [ -f ${DOTFILES_DIR}/scripts/identify_platform.sh ]; then
    . ${HOME}/.dotfiles/scripts/identify_platform.sh
    export PLATFORM_ID=${DistroBasedOn}-${MAJOR_REV}-${MACH}
fi