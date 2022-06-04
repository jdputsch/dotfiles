#
# Setup environment variable for Python/pip
#
# Authors:
#   Jeff Putsch <jdputsch@gmail.com>
#

export PIP_REQUIRE_VIRTUALENV=true

# If /usr/sepp/bin does not exist, then enable pyenv
[ ! -d /usr/sepp/bin ] && disable-pyenv

# Local Variables:
# mode: sh
# eval: (sh-set-shell "zsh")
# End:
