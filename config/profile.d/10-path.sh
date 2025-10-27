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
# - path/PATH: Executable search paths
# - manpath/MANPATH: Manual page search paths
# - infopath/INFOPATH: Info document search paths
# - cdpath/CDPATH: Directory search paths for cd command
# - fpath/FPATH: Function search paths (Zsh)
# - mailpath/MAILPATH: Mail file search paths
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
# - ZSH_DEBUG: Debug logging when set
#
# Author: Jeff Putsch
# Part of: dotfiles configuration
# Location: config/profile.d/10-path.sh
#

# If modules is available, use it, else manage key paths here
if [ -f /usr/cadtools/bin/modules.dir/Shrc ]; then
    if [[ -o login ]]; then
      . /usr/cadtools/bin/modules.dir/Shrc
    fi
else
    # Paths - make sure these have unique entries, then set default vaules
    typeset -gU cdpath fpath mailpath manpath path
    typeset -gUT INFOPATH infopath
    
    # Set the the list of directories that cd searches.
    cdpath=(
      $cdpath
    )
    
    # Set the list of directories that `info` searches for manuals.
    infopath=(
      /usr/local/share/info
      /usr/share/info
      $infopath
    )
    
    # OSX has a path helper (/usr/libexec/path_helper) to set PATH and MANPATH
    # variables, normally I would use it, but I use APFs on Mac, therefore I don't
    # use path helper anymore: on APFS, the order of files read from /etc/paths.d
    # is not ascii/numeric anymore. therfore, we'll emulate it here.
    
    
    
    # Set the list of directories that Zsh searches for programs.
    if [[ $OSTYPE = darwin* ]] && [ -x /usr/libexec/path_helper ]; then
    	eval `/usr/libexec/path_helper -s`
    else
      # Set the list of directories that man searches for manuals.
      if [[ $OSTYPE != darwin* ]]; then
          manpath=(
            /usr/local/share/man
            /usr/share/man
            $manpath
          )
        for path_file in /etc/manpaths.d/*(.N); do
          manpath+=($(<$path_file))
        done
        unset path_file
      fi
      # Now set path entries
      path=(
        /usr/local/{bin,sbin}
        /usr/{bin,sbin}
        /{bin,sbin}
        ~/bin
        $path
      )
      for path_file in /etc/paths.d/*(.N); do
        path+=($(<$path_file))
      done
      unset path_file
    fi
    
    # Add personal, custom paths
    for path_file in ${HOME}/.paths.d/*(@N,.N); do
      [ -e $HOME/ZSH_DEBUG ] && echo ".zshenv: settings paths from $path_file" >> $HOME/ZSH_DEBUG
       for path_elem in $(cat ${path_file}); do
           if [ -d ${(e)path_elem} ]; then
               path+=(${(e)path_elem})
           fi
       done
       unset path_elem
    done
    unset path_file
    
    # Move some path elements to the beginning of our search path
    if [ -n "${PLATFORM_ID}" ] && [ -d ${HOME}/${PLAT}/bin ]; then
        path=( ${HOME}/${PLATFORM_ID}/bin $path)
    fi
    
    # Remove path elements that start with "/tmp/" -- a Maxim/Linux artifact:
    path=("${(@)path:#/tmp/*}")

    # MacOSX
    if [[ "$OSTYPE" = darwin*  && -d /opt/pkg ]]; then
      infopath=(
        $infopath
        /opt/pkg/info
      )
    fi
    
    # Linux
    if [[ "$OSTYPE" = linux* ]]; then
        [[ -d /usr/sepp/man ]] && manpath=($manpath /usr/sepp/man)
        [[ -d /home/tekcad/local/man ]] && manpath=($manpath /home/tekcad/local/man)
    fi
fi
