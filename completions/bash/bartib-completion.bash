#!/bin/bash
# Bash completion for bartib time tracker
# Uses shared data from completions/core/bartib-data

# Source shared bartib data functions
. "${DOTFILES_DIR}/completions/core/bartib-data"

_bartib_completion() {
    local cur prev words cword
    _init_completion || return

    local subcommands="cancel change check continue current edit help last list projects report sanity search start status stop"
    
    # Complete subcommands
    if [ $cword -eq 1 ]; then
        COMPREPLY=($(compgen -W "$subcommands" -- "$cur"))
        return 0
    fi

    # Complete based on subcommand
    local subcommand="${words[1]}"
    case "$subcommand" in
        start|change|continue)
            case "$prev" in
                -p|--project)
                    COMPREPLY=($(compgen -W "$(__bartib_get_projects)" -- "$cur"))
                    return 0
                    ;;
                -d|--description)
                    # No completion for description
                    return 0
                    ;;
                -t|--time)
                    # Could add time format hints here
                    return 0
                    ;;
            esac
            
            # Complete options
            local opts="-h --help -p --project -d --description -t --time"
            COMPREPLY=($(compgen -W "$opts" -- "$cur"))
            ;;
            
        continue|edit)
            if [[ "$cur" =~ ^[0-9] ]]; then
                # Complete task numbers - simplified for bash
                local tasks=$(__bartib_get_tasks | cut -d'[' -f1)
                COMPREPLY=($(compgen -W "$tasks" -- "$cur"))
            else
                local opts="-h --help -p --project -d --description -t --time"
                COMPREPLY=($(compgen -W "$opts" -- "$cur"))
            fi
            ;;
            
        list|report)
            case "$prev" in
                -p|--project)
                    COMPREPLY=($(compgen -W "$(__bartib_get_projects)" -- "$cur"))
                    return 0
                    ;;
                -d|--date|--from|--to)
                    # Could add date completion here
                    return 0
                    ;;
                -n|--number|--round)
                    # No completion for numbers
                    return 0
                    ;;
            esac
            
            local opts="-h --help --current-week --last-week --today --yesterday --no-grouping"
            opts="$opts -d --date --from --to -n --number -p --project --round"
            COMPREPLY=($(compgen -W "$opts" -- "$cur"))
            ;;
            
        projects)
            local opts="-h --help -c --current -n --no-quotes"
            COMPREPLY=($(compgen -W "$opts" -- "$cur"))
            ;;
            
        search)
            case "$prev" in
                -p|--project)
                    COMPREPLY=($(compgen -W "$(__bartib_get_projects)" -- "$cur"))
                    return 0
                    ;;
            esac
            
            local opts="-h --help -p --project"
            COMPREPLY=($(compgen -W "$opts" -- "$cur"))
            ;;
            
        last)
            case "$prev" in
                -n|--number)
                    return 0
                    ;;
            esac
            
            local opts="-h --help -n --number"
            COMPREPLY=($(compgen -W "$opts" -- "$cur"))
            ;;
            
        stop)
            case "$prev" in
                -t|--time)
                    return 0
                    ;;
            esac
            
            local opts="-h --help -t --time"
            COMPREPLY=($(compgen -W "$opts" -- "$cur"))
            ;;
            
        help)
            COMPREPLY=($(compgen -W "$subcommands" -- "$cur"))
            ;;
            
        *)
            local opts="-h --help"
            COMPREPLY=($(compgen -W "$opts" -- "$cur"))
            ;;
    esac
}

# Register the completion
complete -F _bartib_completion bartib