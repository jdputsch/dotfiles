#
# Setup environment variable for Perforce and IC Manage

# Authors:
#   Jeff Putsch <jdputsch@gmail.com>
#

if [[ ${OS} = "darwin" ]]; then
    export P4CONFIG=.p4config
    export P4PORT=perforce.maxim-ic.com:2666
fi

# export P4USER=jputsch

# Local Variables:
# mode: sh
# eval: (sh-set-shell "zsh")
# End:
