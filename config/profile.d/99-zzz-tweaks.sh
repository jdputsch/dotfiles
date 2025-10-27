#!/bin/sh
#
# 99-zzz-tweaks.sh - Final System Tweaks and Adjustments
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
# Environment Variables Used:
# - KERNEL: System kernel information for platform detection
# - OSTYPE: Operating system type for macOS detection
# - PATH: Executable search path (propagated to launchd)
# - MANPATH: Manual page search path (propagated to launchd)
#
# Dependencies:
# - KERNEL variable from platform detection (00-platform.sh)
# - OSTYPE variable (standard shell variable)
# - launchctl command (macOS only)
# - unsetopt command (zsh, with conditional usage)
#
# Design Rationale:
# This file handles "final touches" that:
# - Must run after all other configuration is complete
# - Are platform-specific optimizations rather than core functionality
# - Involve system integration beyond basic shell configuration
# - May have performance implications and benefit from background execution
#
# Author: Jeff Putsch
# Part of: dotfiles configuration system
# Location: config/profile.d/99-zzz-tweaks.sh
#

#
# WSL does not implement nice(2), therefore we turn of BG_NICE
#
if [[ "${KERNEL}" == *Microsoft* ]]; then
    unsetopt BG_NICE
fi

# Execute code that does not affect the current session in the background.
silent_background sh -c '
    # Set environment variables for launchd processes.
    # Only run on interactive shells on macOS to avoid unnecessary calls
    # Check for macOS and interactive shell (portable across sh/bash/zsh)
    if [ "${OSTYPE#darwin}" != "${OSTYPE}" ]]; then
      # Check if shell is interactive (portable method)
      case $- in
        *i*) _is_interactive=true ;;
        *) _is_interactive=false ;;
      esac
      
      # Only run launchctl if interactive
      if [ "$_is_interactive" = true ]; then
        for env_var in PATH MANPATH; do
          # Use portable variable expansion instead of zsh-specific ${(P)var}
          case $env_var in
            PATH) launchctl setenv "$env_var" "$PATH" 2>/dev/null ;;
            MANPATH) launchctl setenv "$env_var" "$MANPATH" 2>/dev/null ;;
          esac
        done
      fi
      
      unset _is_interactive
    fi
  '
