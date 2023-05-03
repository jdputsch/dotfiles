#
# Setup environment variable for Perforce and IC Manage

# Authors:
#   Jeff Putsch <jdputsch@gmail.com>
#

if [[ ${OS} = "darwin" ]]; then
    export P4CONFIG=.p4config
    export P4PORT=sjp4edge1.adsiv.analog.com:1666
    export P4USER=jputsch

    if [ -x /Applications/p4merge.app/Contents/MacOS/p4merge ]; then
        p4merge() {
            /Applications/p4merge.app/Contents/MacOS/p4merge "$@"
        }
    fi
fi

# export P4USER=jputsch

# Local Variables:
# mode: sh
# eval: (sh-set-shell "zsh")
# End:
