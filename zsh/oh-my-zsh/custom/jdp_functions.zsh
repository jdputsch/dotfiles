# Use /usr/sepp/bin/git when on Linux and it is available
function git() {
    if [[ ${OS} = linux ]]\
       && [[ -x /usr/sepp/bin/git ]]; then
        /usr/sepp/bin/git "$@"
    else
        /usr/bin/env git "$@"
    fi
}
