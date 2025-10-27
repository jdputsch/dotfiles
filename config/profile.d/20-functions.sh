#!/bin/sh
#
# 20-functions.sh - Cross-Shell Function Management
#
# This script loads shell functions in a way that's compatible across sh, bash, 
# and zsh. Functions are organized by compatibility level and loaded appropriately
# for each shell type.
#
# Directory Structure:
# - functions/core/           POSIX-compatible functions (all shells)
# - functions/extended/       Advanced functions (bash/zsh only)
# - functions/shell-specific/ Shell-optimized implementations
#   - shell-specific/sh/            POSIX sh specific functions
#   - shell-specific/bash/          Bash-specific functions
#   - shell-specific/zsh/           Zsh-specific functions
#
# Loading Order:
# 1. Core functions (universal compatibility)
# 2. Extended functions (if shell supports advanced features)
# 3. Shell-specific functions (optimized for current shell)
#
# Environment Variables Used:
# - DOTFILES_DIR: Root directory of dotfiles (set by 00-platform.sh)
# - ZSH_VERSION: Zsh version detection
# - BASH_VERSION: Bash version detection
#
# Dependencies:
# - DOTFILES_DIR must be set (from 00-platform.sh)
# - Function files must be readable and properly formatted
#
# Author: Jeff Putsch
# Part of: dotfiles configuration system
# Location: config/profile.d/20-functions.sh
#

# Ensure DOTFILES_DIR is set
if [ -z "$DOTFILES_DIR" ]; then
    echo "Warning: DOTFILES_DIR not set, cannot load shell functions" >&2
    return 1
fi

# Function to source all files in a directory
load_functions_from_dir() {
    local func_dir="$1"
    local loaded_count=0
    
    if [ -d "$func_dir" ]; then
        # Set nullglob behavior for safe iteration
        if [ -n "$ZSH_VERSION" ]; then
            setopt local_options null_glob
        fi
        
        # Use nullglob-safe iteration
        for func_file in "$func_dir"/*; do
            # Check if glob expansion found actual files
            [ -e "$func_file" ] || continue
            
            if [ -f "$func_file" ] && [ -r "$func_file" ]; then
                # Skip backup files and hidden files
                case "$(basename "$func_file")" in
                    .*|*~|*.bak|*.orig) continue ;;
                esac
                
                # Source with error handling
                if . "$func_file" 2>/dev/null; then
                    loaded_count=$((loaded_count + 1))
                elif [ -n "$ZSH_DEBUG" ]; then
                    echo "20-functions.sh: Failed to load $func_file" >> "$HOME/ZSH_DEBUG"
                fi
            fi
        done
    fi
    
    # Debug output if ZSH_DEBUG is set
    if [ -n "$ZSH_DEBUG" ]; then
        echo "20-functions.sh: Loaded $loaded_count functions from $func_dir" >> "$HOME/ZSH_DEBUG"
    fi
}

# Detect shell type and capabilities
if [ -n "$ZSH_VERSION" ]; then
    SHELL_TYPE="zsh"
    HAS_ADVANCED_FEATURES=true
elif [ -n "$BASH_VERSION" ]; then
    SHELL_TYPE="bash"
    HAS_ADVANCED_FEATURES=true
else
    SHELL_TYPE="sh"
    HAS_ADVANCED_FEATURES=false
fi

# Load core POSIX-compatible functions (all shells)
load_functions_from_dir "${DOTFILES_DIR}/functions/core"

# Load extended functions (bash/zsh only)
if [ "$HAS_ADVANCED_FEATURES" = "true" ]; then
    load_functions_from_dir "${DOTFILES_DIR}/functions/extended"
fi

# Load shell-specific functions
load_functions_from_dir "${DOTFILES_DIR}/functions/shell-specific/${SHELL_TYPE}"

# For zsh, also add to fpath for autoloading if directories exist
if [ "$SHELL_TYPE" = "zsh" ]; then
    # Set nullglob for safe autoloading
    setopt local_options null_glob
    
    # Add functions directories to fpath for autoloading
    local func_dirs=(
        "${DOTFILES_DIR}/functions/shell-specific/zsh"
        "${DOTFILES_DIR}/functions/extended"
        "${DOTFILES_DIR}/functions/core"
    )
    
    for func_dir in "${func_dirs[@]}"; do
        if [ -d "$func_dir" ]; then
            fpath=("$func_dir" $fpath)
        fi
    done
    
    # Autoload functions that haven't been sourced yet
    # This allows for lazy loading of zsh functions
    for func_dir in "${func_dirs[@]}"; do
        if [ -d "$func_dir" ]; then
            for func_file in "$func_dir"/*; do
                [ -e "$func_file" ] || continue
                if [ -f "$func_file" ]; then
                    func_name="$(basename "$func_file")"
                    case "$func_name" in
                        .*|*~|*.bak|*.orig) continue ;;
                    esac
                    # Only autoload if not already defined as a function
                    if ! typeset -f "$func_name" > /dev/null 2>&1; then
                        autoload -Uz "$func_name" 2>/dev/null
                    fi
                fi
            done
        fi
    done
fi

# Clean up temporary variables
unset -f load_functions_from_dir
unset SHELL_TYPE HAS_ADVANCED_FEATURES

# Debug output
if [ -n "$ZSH_DEBUG" ]; then
    echo "20-functions.sh: Function loading completed" >> "$HOME/ZSH_DEBUG"
fi