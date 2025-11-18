#!/bin/sh
#
# 10-path.sh - Shell Environment Path Configuration
#
# This script configures essential search paths for shell environments, including
# PATH, MANPATH, INFOPATH, and other system paths. It's designed to work across
# different operating systems (macOS, Linux) and handles both module-based and
# traditional path management approaches.
#
# Key Features:
# - Automatic detection and use of module systems when available
# - Cross-platform path configuration (macOS, Linux)
# - Custom path directory support via ~/.paths.d/
# - Platform-specific path handling (PLATFORM_ID variable)
# - Cleanup of temporary/unwanted path entries
# - Unique path entry enforcement to prevent duplicates
#
# Path Variables Managed:
# - PATH: Executable search paths
# - MANPATH: Manual page search paths
# - INFOPATH: Info document search paths
# - CDPATH: Directory search paths for cd command
#
# Platform Support:
# - macOS: Uses path_helper when available, handles APFS considerations
# - Linux: Manual path configuration with Sepp and tekcad support
# - Generic Unix: Fallback configuration for other systems
#
# Custom Path Configuration:
# - Add files to ~/.paths.d/ to include custom paths
# - Files can contain multiple paths (one per line)
# - Variable expansion is supported in path definitions
# - Only existing directories are added to paths
#
# Module System Integration:
# - Automatically detects /usr/cadtools/bin/modules.dir/Shrc
# - Falls back to manual path management if modules unavailable
#
# Environment Variables Used:
# - OSTYPE: Operating system detection
# - PLATFORM_ID: Platform-specific binary directory
# - HOME: User home directory
#
# Author: Jeff Putsch
# Part of: dotfiles configuration
# Location: config/profile.d/10-path.sh
#

# Setup debugging if PATH_DEBUG file exists
# Remember if PATH_DEBUG was already set
was_path_debug_set=
[ -n "$PATH_DEBUG" ] && was_path_debug_set=1

if [ -f "$HOME/PATH_DEBUG" ]; then
    PATH_DEBUG=1
    echo "10-path.sh: Starting path configuration" >> "$HOME/PATH_DEBUG"
fi

# Helper function to add to path if directory exists and isn't already in path
add_to_path() {
    if [ -d "$1" ]; then
        case ":$PATH:" in
            *":$1:"*)
                [ -n "$PATH_DEBUG" ] && echo "10-path.sh: Directory $1 already in PATH" >> "$HOME/PATH_DEBUG"
                ;; # Already in path
            *)
                PATH="$1:$PATH"
                [ -n "$PATH_DEBUG" ] && echo "10-path.sh: Added $1 to PATH" >> "$HOME/PATH_DEBUG"
                ;;
        esac
    else
        [ -n "$PATH_DEBUG" ] && echo "10-path.sh: Directory $1 does not exist, skipping" >> "$HOME/PATH_DEBUG"
    fi
}

# Helper function to add to manpath if directory exists
add_to_manpath() {
    if [ -d "$1" ]; then
        case ":${MANPATH-}:" in
            *":$1:"*)
                [ -n "$PATH_DEBUG" ] && echo "10-path.sh: Directory $1 already in MANPATH" >> "$HOME/PATH_DEBUG"
                ;; # Already in manpath
            *)
                MANPATH="${MANPATH:+$MANPATH:}$1"
                [ -n "$PATH_DEBUG" ] && echo "10-path.sh: Added $1 to MANPATH" >> "$HOME/PATH_DEBUG"
                ;;
        esac
    else
        [ -n "$PATH_DEBUG" ] && echo "10-path.sh: Directory $1 does not exist, skipping MANPATH" >> "$HOME/PATH_DEBUG"
    fi
}

# Helper function to add to infopath if directory exists
add_to_infopath() {
    if [ -d "$1" ]; then
        case ":${INFOPATH-}:" in
            *":$1:"*)
                [ -n "$PATH_DEBUG" ] && echo "10-path.sh: Directory $1 already in INFOPATH" >> "$HOME/PATH_DEBUG"
                ;; # Already in infopath
            *)
                INFOPATH="${INFOPATH:+$INFOPATH:}$1"
                [ -n "$PATH_DEBUG" ] && echo "10-path.sh: Added $1 to INFOPATH" >> "$HOME/PATH_DEBUG"
                ;;
        esac
    else
        [ -n "$PATH_DEBUG" ] && echo "10-path.sh: Directory $1 does not exist, skipping INFOPATH" >> "$HOME/PATH_DEBUG"
    fi
}

# If modules is available, use it
if [ -f /usr/cadtools/bin/modules.dir/Shrc ]; then
    [ -n "$PATH_DEBUG" ] && echo "10-path.sh: Using module system from /usr/cadtools/bin/modules.dir/Shrc" >> "$HOME/PATH_DEBUG"
    # Check if this is being sourced by a login shell
    case "$0" in
        -*) . /usr/cadtools/bin/modules.dir/Shrc ;;
    esac
else
    [ -n "$PATH_DEBUG" ] && echo "10-path.sh: Module system not available, using manual path configuration" >> "$HOME/PATH_DEBUG"
    # Initialize paths if not already set
    : "${MANPATH:=}"
    : "${INFOPATH:=}"
    : "${CDPATH:=}"

    # Add standard info directories
    add_to_infopath /usr/local/share/info
    add_to_infopath /usr/share/info

    # OSX path helper handling
    case "${OSTYPE-}" in
        darwin*)
            if [ -x /usr/libexec/path_helper ]; then
                [ -n "$PATH_DEBUG" ] && echo "10-path.sh: Using macOS path_helper" >> "$HOME/PATH_DEBUG"
                eval "$(/usr/libexec/path_helper -s)"
            fi
            ;;
        *)
            [ -n "$PATH_DEBUG" ] && echo "10-path.sh: Adding standard man directories for non-Darwin systems" >> "$HOME/PATH_DEBUG"
            # Add standard man directories on non-Darwin systems
            add_to_manpath /usr/local/share/man
            add_to_manpath /usr/share/man

            # Process manpaths from /etc/manpaths.d
            if [ -d /etc/manpaths.d ]; then
                [ -n "$PATH_DEBUG" ] && echo "10-path.sh: Processing manpaths from /etc/manpaths.d" >> "$HOME/PATH_DEBUG"
                for path_file in /etc/manpaths.d/*; do
                    if [ -f "$path_file" ]; then
                        [ -n "$PATH_DEBUG" ] && echo "10-path.sh: Reading manpaths from $path_file" >> "$HOME/PATH_DEBUG"
                        while read -r dir; do
                            [ -n "$dir" ] && add_to_manpath "$dir"
                        done < "$path_file"
                    fi
                done
            fi

            # Add standard binary paths
            [ -n "$PATH_DEBUG" ] && echo "10-path.sh: Adding standard binary paths" >> "$HOME/PATH_DEBUG"
            for dir in \
                "$HOME/bin" \
                /usr/local/bin \
                /usr/local/sbin \
                /usr/bin \
                /usr/sbin \
                /bin \
                /sbin; do
                add_to_path "$dir"
            done

            # Process paths from /etc/paths.d
            if [ -d /etc/paths.d ]; then
                [ -n "$PATH_DEBUG" ] && echo "10-path.sh: Processing paths from /etc/paths.d" >> "$HOME/PATH_DEBUG"
                for path_file in /etc/paths.d/*; do
                    if [ -f "$path_file" ]; then
                        [ -n "$PATH_DEBUG" ] && echo "10-path.sh: Reading paths from $path_file" >> "$HOME/PATH_DEBUG"
                        while read -r dir; do
                            [ -n "$dir" ] && add_to_path "$dir"
                        done < "$path_file"
                    fi
                done
            fi
            ;;
    esac

    # Process personal custom paths from ~/.paths.d
    if [ -d "${HOME}/.paths.d" ]; then
        [ -n "$PATH_DEBUG" ] && echo "10-path.sh: Processing custom paths from ~/.paths.d" >> "$HOME/PATH_DEBUG"
        for path_file in "${HOME}"/.paths.d/*; do
            if [ -f "$path_file" ]; then
                [ -n "$PATH_DEBUG" ] && echo "10-path.sh: Reading custom paths from $path_file" >> "$HOME/PATH_DEBUG"
                while read -r path_elem; do
                    case "$path_elem" in
                        ""|\#*) continue ;; # Skip empty lines and comments
                        *)
                            # Expand any variables in the path
                            eval "path_elem=$path_elem"
                            [ -d "$path_elem" ] && add_to_path "$path_elem"
                            ;;
                    esac
                done < "$path_file"
            fi
        done
    fi

    # Add platform-specific paths
    if [ -n "${PLATFORM_ID-}" ] && [ -d "${HOME}/${PLATFORM_ID}/bin" ]; then
        [ -n "$PATH_DEBUG" ] && echo "10-path.sh: Adding platform-specific path for ${PLATFORM_ID}" >> "$HOME/PATH_DEBUG"
        add_to_path "${HOME}/${PLATFORM_ID}/bin"
    fi

    # Remove /tmp paths
    [ -n "$PATH_DEBUG" ] && echo "10-path.sh: Removing /tmp paths from PATH" >> "$HOME/PATH_DEBUG"
    new_path=""
    saved_ifs=$IFS
    IFS=:
    for p in $PATH; do
        case "$p" in
            /tmp/*)
                [ -n "$PATH_DEBUG" ] && echo "10-path.sh: Removed /tmp path: $p" >> "$HOME/PATH_DEBUG"
                continue
                ;;
            *) new_path="${new_path:+$new_path:}$p" ;;
        esac
    done
    IFS=$saved_ifs
    PATH=$new_path
    unset new_path saved_ifs p

    # OS-specific paths
    [ -n "$PATH_DEBUG" ] && echo "10-path.sh: Adding OS-specific paths for ${OSTYPE-}" >> "$HOME/PATH_DEBUG"
    case "${OSTYPE-}" in
        darwin*)
            # MacOSX specific paths
            if [ -d /opt/pkg ]; then
                add_to_infopath /opt/pkg/info
            fi
            ;;
        linux*)
            # Linux specific paths
            [ -d /usr/sepp/man ] && add_to_manpath /usr/sepp/man
            [ -d /home/tekcad/local/man ] && add_to_manpath /home/tekcad/local/man
            ;;
    esac

    # Export all modified path variables
    export PATH MANPATH INFOPATH CDPATH
fi

# Final debug output
if [ -n "$PATH_DEBUG" ]; then
    echo "10-path.sh: Path configuration completed" >> "$HOME/PATH_DEBUG"
    echo "10-path.sh: Final PATH=$PATH" >> "$HOME/PATH_DEBUG"
    echo "10-path.sh: Final MANPATH=$MANPATH" >> "$HOME/PATH_DEBUG"
    echo "10-path.sh: Final INFOPATH=$INFOPATH" >> "$HOME/PATH_DEBUG"
    # Unset PATH_DEBUG if we set it in this script
    [ -z "$was_path_debug_set" ] && unset PATH_DEBUG
fi
unset was_path_debug_set
