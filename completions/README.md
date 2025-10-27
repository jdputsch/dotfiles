# Shell Completions System

This directory contains a cross-shell completion management system that provides command completion for both zsh and bash while minimizing file duplication.

## Directory Structure

```
completions/
├── core/                   # Shared completion data and cross-shell functions
│   ├── completion-utils    # Common completion utility functions
│   └── bartib-data        # Shared bartib completion data
├── zsh/                   # Zsh-specific completion files
│   ├── _bartib           # Zsh completion for bartib
│   └── _cargo            # Zsh completion for cargo
├── bash/                 # Bash-specific completion files
│   └── bartib-completion.bash  # Bash completion for bartib
├── generators/           # Scripts to auto-generate completions
│   └── generate-tool-completions  # Generator for tools that support it
└── README.md            # This file
```

## Design Philosophy

### Minimizing Duplication
1. **Shared Data**: Common completion data (like lists of subcommands, options) is stored in `core/` and sourced by both shell-specific completions
2. **Utility Functions**: Cross-shell compatible functions for common completion tasks
3. **Generated Completions**: Auto-generate completions for tools that support it
4. **Legacy Compatibility**: Maintains compatibility with existing completion files

### Shell-Specific Optimizations
- **Zsh**: Uses advanced zsh completion features like `_describe`, `_arguments`, etc.
- **Bash**: Uses bash completion framework with `complete` and `compgen`
- **Shared Logic**: Data extraction and common logic shared between shells

## Types of Completions

### 1. Shared Data Completions (`core/`)
Files that provide data and utility functions used by multiple completion scripts:
- **completion-utils**: Cross-shell utility functions (SSH hosts, git branches, etc.)
- **bartib-data**: Bartib-specific data functions (projects, tasks, etc.)

### 2. Custom Shell Completions
Hand-written completions optimized for each shell:
- **Zsh**: Uses zsh completion system features
- **Bash**: Uses bash-completion framework

### 3. Generated Completions (`generators/`)
Auto-generated completions for tools that support generating their own:
- gh, docker, kubectl, helm, pip, etc.
- Automatically refreshed when older than 7 days

### 4. System/Package Completions
Completions provided by the system or package managers:
- Often just need to be sourced or enabled
- Example: cargo completion from rustup

## Loading System

Completions are loaded by `config/profile.d/25-completions.sh`:

1. **Load shared utilities** from `core/`
2. **Set up shell-specific paths** (fpath for zsh, bash-completion for bash)
3. **Load shell-specific completions**
4. **Generate missing completions** using generators
5. **Maintain backward compatibility** with legacy locations

## Adding New Completions

### For Tools with Built-in Completion Generation
1. Add the tool to `generators/generate-tool-completions`
2. The system will auto-generate completions for both shells

### For Custom Completions

#### Step 1: Create Shared Data (if needed)
```bash
# completions/core/tool-data
. "${DOTFILES_DIR}/completions/core/completion-utils"

__tool_get_subcommands() {
    echo "subcommand1 subcommand2 subcommand3"
}

__tool_get_options() {
    echo "--option1 --option2 --help"
}
```

#### Step 2: Create Zsh Completion
```bash
#compdef tool

. "${DOTFILES_DIR}/completions/core/tool-data"

_tool() {
    local context state line
    typeset -A opt_args

    _arguments \
        '--option1[Description]' \
        '--option2[Description]' \
        '1: :_tool_commands' \
        '*:: :->args'
}

_tool_commands() {
    local -a commands
    commands=(${(f)"$(__tool_get_subcommands)"})
    _describe 'command' commands
}

_tool "$@"
```

#### Step 3: Create Bash Completion
```bash
#!/bin/bash
. "${DOTFILES_DIR}/completions/core/tool-data"

_tool_completion() {
    local cur prev words cword
    _init_completion || return

    if [ $cword -eq 1 ]; then
        COMPREPLY=($(compgen -W "$(__tool_get_subcommands)" -- "$cur"))
        return 0
    fi

    # Add more completion logic here
}

complete -F _tool_completion tool
```

## Migration from Legacy Completions

### From `zsh/functions/_*`
1. **Analyze the completion**: Determine if it's custom or can be generated
2. **Extract shared data**: Move common data to `core/` if it could be useful for bash
3. **Create new versions**: Place zsh-specific in `completions/zsh/`
4. **Create bash equivalent**: If useful, create bash version
5. **Test both shells**: Ensure functionality works correctly

### Migration Example: `_bartib`
- **Before**: Single zsh-only file with embedded data
- **After**: 
  - Shared data functions in `core/bartib-data`
  - Optimized zsh completion in `zsh/_bartib`
  - New bash completion in `bash/bartib-completion.bash`

## Testing Completions

### Test in Zsh
```bash
# Load completion system
export DOTFILES_DIR="$PWD" && . config/profile.d/25-completions.sh

# Test completion
tool <TAB>
tool subcommand --<TAB>
```

### Test in Bash
```bash
# Load completion system  
export DOTFILES_DIR="$PWD" && . config/profile.d/25-completions.sh

# Test completion
tool <TAB><TAB>
tool subcommand --<TAB><TAB>
```

## Debug Information

Enable debug output:
```bash
export COMPLETION_DEBUG=1
# Check ~/completion_debug.log for loading information
```

## Maintenance

### Updating Generated Completions
Generated completions are automatically refreshed if older than 7 days. To force refresh:
```bash
rm completions/{zsh,bash}/_tool_name*
. config/profile.d/25-completions.sh  # Will regenerate
```

### Adding New Tools
1. For auto-generating tools: Add to `generators/generate-tool-completions`
2. For custom tools: Create shared data and shell-specific completions
3. Test in both shells
4. Update this documentation

### Best Practices
- Keep shared data in `core/` files
- Use shell-specific optimizations in shell directories
- Test completions in both zsh and bash
- Document complex completion logic
- Use meaningful file names and consistent patterns