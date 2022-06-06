#
# Setup default printer on Linux (Mac is OK for now).

# Authors:
#   Jeff Putsch <jdputsch@gmail.com>
#

# TODO: add print-to command allowing me to set printer easily

if [[ $(uname) = Linux ]]; then
    export CUPS_USER=Jeff.Putsch
    export PRINTER=MFNPrint
    export LPDEST=${PRINTER}
fi

# Local Variables:
# mode: sh
# eval: (sh-set-shell "zsh")
# End:
