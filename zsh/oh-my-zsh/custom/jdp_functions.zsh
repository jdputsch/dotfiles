# Use /usr/sepp/bin/git when on Linux and it is available
if [[ ${OS} = linux ]] && [[ -x /usr/sepp/bin/git ]]; then
    function git() {
        /usr/sepp/bin/git "$@"
    }
fi
