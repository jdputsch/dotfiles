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
}

# NVM / Node.js functions
lazynvm() {
  unset -f nvm node npm
  # export NVM_DIR=~/.nvm
  . /opt/local/share/nvm/init-nvm.sh
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
}

nvm() {
  lazynvm 
  nvm $@
}
 
node() {
  lazynvm
  node $@
}
 
npm() {
  lazynvm
  npm $@
}

npx() {
  lazynvm
  npx $@
}
