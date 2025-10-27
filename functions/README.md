# Shell Functions System

This directory contains a cross-shell function management system that provides consistent function availability across sh, bash, and zsh.

## Directory Structure

```
functions/
├── core/                    # POSIX-compatible functions (sh/bash/zsh)
├── extended/               # Advanced functions (bash/zsh only)
├── shell-specific/         # Shell-optimized implementations
│   ├── sh/                # POSIX sh specific functions
│   ├── bash/              # Bash-specific functions
│   └── zsh/               # Zsh-specific functions
└── README.md              # This file
```

## Function Categories

### Core Functions (`core/`)
- **Compatibility**: sh, bash, zsh
- **Requirements**: POSIX-compliant only
- **Features**: Basic functionality using portable syntax
- **Examples**: `mkcd`, `extract`

### Extended Functions (`extended/`)
- **Compatibility**: bash, zsh only
- **Requirements**: Arrays, advanced parameter expansion
- **Features**: More sophisticated functionality
- **Examples**: `path_manipulate` (path_remove, path_prepend, path_append)

### Shell-Specific Functions (`shell-specific/`)
- **Compatibility**: Optimized for specific shells
- **Requirements**: Shell-specific features
- **Features**: Maximum functionality using shell capabilities
- **Examples**: `freload` (different implementations per shell)

## Loading System

Functions are loaded by `config/profile.d/20-functions.sh` in this order:

1. **Core functions** - Available in all shells
2. **Extended functions** - Only in bash/zsh
3. **Shell-specific functions** - Optimized for current shell

### Zsh Integration
- Functions are added to `fpath` for autoloading
- Supports both immediate loading and lazy autoloading
- Compatible with existing zsh function management

### Bash Integration
- Functions are sourced directly
- Support for function reloading via `freload`
- Compatible with bash function conventions

### POSIX sh Integration
- Only core functions are loaded
- Minimal resource usage
- Maximum compatibility

## Adding New Functions

### Core Function Template
```bash
#!/bin/sh
# functions/core/function_name
# Description: What this function does
# Usage: function_name [args]
# Compatibility: sh, bash, zsh

function_name() {
    # POSIX-compatible implementation
    # Use [ ] instead of [[ ]]
    # Avoid arrays, use positional parameters
    # Use portable variable expansion
}
```

### Extended Function Template
```bash
#!/bin/bash
# functions/extended/function_name
# Description: What this function does
# Usage: function_name [args]
# Compatibility: bash, zsh
# Requires: Arrays, advanced features

function_name() {
    # Can use arrays, [[ ]], advanced features
    # Still avoid shell-specific syntax
}
```

### Shell-Specific Function Template
```bash
# functions/shell-specific/zsh/function_name
# Description: What this function does
# Usage: function_name [args]
# Compatibility: zsh only
# Features: Uses zsh-specific features for optimization

function_name() {
    # Full zsh feature set available
    # Optimized for zsh capabilities
}
```

## Migration from Legacy Systems

### From `zsh/functions/`
1. Analyze function for compatibility level
2. Move to appropriate directory:
   - POSIX-compatible → `core/`
   - Bash/zsh features → `extended/`
   - Zsh-specific → `shell-specific/zsh/`
3. Update any hardcoded paths in the function
4. Test across target shells

### From `bash/` or other shell configs
1. Extract function definitions
2. Categorize by compatibility
3. Place in appropriate directory
4. Update function loading scripts

## Testing Functions

Test functions across shells:
```bash
# Test in current shell
function_name test_args

# Test in specific shell
zsh -c ". ~/.dotfiles/config/profile.d/20-functions.sh; function_name test_args"
bash -c ". ~/.dotfiles/config/profile.d/20-functions.sh; function_name test_args"
sh -c ". ~/.dotfiles/config/profile.d/20-functions.sh; function_name test_args"
```

## Debug Information

Set `ZSH_DEBUG` environment variable to get loading information:
```bash
export ZSH_DEBUG="$HOME/shell_debug.log"
```

## Maintenance

- Keep functions focused and single-purpose
- Document compatibility requirements clearly
- Test changes across all target shells
- Use consistent naming conventions
- Avoid conflicting with system commands

## Legacy Compatibility

The system maintains compatibility with:
- Existing `zsh/functions/` directory (still in fpath)
- Current shell initialization scripts
- Autoloading mechanisms in zsh