#!/bin/sh
#
# 25-completions.sh - Cross-Shell Completion Management
#
# This script sets up command completion for both zsh and bash while minimizing
# file duplication. It handles different types of completions:
#
# 1. Generated completions (from tools like gh, docker, etc.)
# 2. Custom completions (hand-written for specific tools)
# 3. System completions (already available in the system)
# 4. Shared completion logic (cross-shell data/functions)
#
# Directory Structure:
# - completions/core/      Shared completion data and cross-shell functions
# - completions/zsh/       Zsh-specific completion files
# - completions/bash/      Bash-specific completion files  
# - completions/generators/ Scripts to generate completions from tools
#
# Loading Strategy:
# 1. Load shared/core completion utilities
# 2. Set up completion paths for the current shell
# 3. Load shell-specific completions
# 4. Generate missing completions if tools support it
#
# Environment Variables Used:
# - DOTFILES_DIR: Root directory of dotfiles (set by 00-platform.sh)
# - ZSH_VERSION: Zsh version detection
# - BASH_VERSION: Bash version detection
# - COMPLETION_DEBUG: Enable debug output for completion loading
#
# Author: Jeff Putsch
# Part of: dotfiles configuration system
# Location: config/profile.d/25-completions.sh
#

if [ -f "$HOME"/DOTFILE_DEBUG ]; then
    echo "DEBUG: Init file: $home/.config/profile.d/25-completions.sh" >&2
fi

# Ensure DOTFILES_DIR is set
if [ -z "$DOTFILES_DIR" ]; then
    echo "Warning: DOTFILES_DIR not set, cannot load completions" >&2
    return 1
fi

# Function to load completions from a directory
load_completions_from_dir() {
    local comp_dir="$1"
    local loaded_count=0
    
    if [ -d "$comp_dir" ]; then
        # Set nullglob behavior for safe iteration
        if [ -n "$ZSH_VERSION" ]; then
            setopt local_options null_glob
        fi
        
        for comp_file in "$comp_dir"/*; do
            # Check if glob expansion found actual files
            [ -e "$comp_file" ] || continue
            
            if [ -f "$comp_file" ] && [ -r "$comp_file" ]; then
                # Skip backup files and hidden files
                case "$(basename "$comp_file")" in
                    .*|*~|*.bak|*.orig|README*) continue ;;
                esac
                
                # Source with error handling
                if . "$comp_file" 2>/dev/null; then
                    loaded_count=$((loaded_count + 1))
                elif [ -n "$COMPLETION_DEBUG" ]; then
                    echo "25-completions.sh: Failed to load $comp_file" >> "$HOME/completion_debug.log"
                fi
            fi
        done
    fi
    
    # Debug output if COMPLETION_DEBUG is set
    if [ -n "$COMPLETION_DEBUG" ]; then
        echo "25-completions.sh: Loaded $loaded_count completions from $comp_dir" >> "$HOME/completion_debug.log"
    fi
}

# Function to generate completions for tools that support it
generate_missing_completions() {
    local generators_dir="${DOTFILES_DIR}/completions/generators"
    
    if [ -d "$generators_dir" ]; then
        for generator in "$generators_dir"/*; do
            [ -f "$generator" ] && [ -x "$generator" ] || continue
            
            # Execute generator script
            if [ -n "$COMPLETION_DEBUG" ]; then
                echo "25-completions.sh: Running generator $(basename "$generator")" >> "$HOME/completion_debug.log"
            fi
            
            "$generator" 2>/dev/null
        done
    fi
}

# Detect shell type
if [ -n "$ZSH_VERSION" ]; then
    SHELL_TYPE="zsh"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_TYPE="bash"
else
    SHELL_TYPE="sh"
    # POSIX sh doesn't have advanced completion, skip
    return 0
fi

# Load core/shared completion utilities first
load_completions_from_dir "${DOTFILES_DIR}/completions/core"

# Set up shell-specific completion system
case "$SHELL_TYPE" in
    "zsh")
        # Add completion directories to fpath (new location first for precedence)
        local comp_dirs=(
            "${DOTFILES_DIR}/completions/zsh"
            "${DOTFILES_DIR}/zsh/functions"  # Legacy location for backward compatibility
        )
        
        for comp_dir in "${comp_dirs[@]}"; do
            if [ -d "$comp_dir" ]; then
                fpath=("$comp_dir" $fpath)
            fi
        done
        
        # Initialize zsh completion system if not already done
        if ! command -v compinit >/dev/null 2>&1; then
            autoload -Uz compinit
        fi
        
        # Load zsh-specific completions (new location first)
        load_completions_from_dir "${DOTFILES_DIR}/completions/zsh"
        
        # Load legacy completions for backward compatibility (only if not already loaded)
        for comp_file in "${DOTFILES_DIR}/zsh/functions"/_*; do
            [ -e "$comp_file" ] || continue
            comp_name="$(basename "$comp_file")"
            # Only load if not already defined from new location
            if ! typeset -f "${comp_name#_}" >/dev/null 2>&1; then
                . "$comp_file" 2>/dev/null
            fi
        done
        ;;
        
    "bash")
        # Enable bash completion if available
        if [ -f /usr/share/bash-completion/bash_completion ]; then
            . /usr/share/bash-completion/bash_completion
        elif [ -f /etc/bash_completion ]; then
            . /etc/bash_completion
        elif [ -f /usr/local/etc/bash_completion ]; then
            # macOS with Homebrew
            . /usr/local/etc/bash_completion
        fi
        
        # Load bash-specific completions
        load_completions_from_dir "${DOTFILES_DIR}/completions/bash"
        ;;
esac

# Generate missing completions
generate_missing_completions

# Clean up
unset -f load_completions_from_dir generate_missing_completions
unset SHELL_TYPE

# Debug output
if [ -n "$COMPLETION_DEBUG" ]; then
    echo "25-completions.sh: Completion loading completed for $SHELL_TYPE" >> "$HOME/completion_debug.log"
fi
