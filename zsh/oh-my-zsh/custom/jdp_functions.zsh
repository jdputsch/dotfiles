# Use /usr/sepp/bin/git when on Linux and it is available
if [[ ${OS} = linux ]] && [[ -x /usr/sepp/bin/git ]]; then
    function git() {
        /usr/sepp/bin/git "$@"
    }
fi

# Shutdown shared ssh connections (controlmasters)
function stop_ssh_cms() {
    for f in $HOME/.ssh/controlmasters/*; do
        host=${${f##*/}%:22}
        ssh -O exit $host 
    done
done
