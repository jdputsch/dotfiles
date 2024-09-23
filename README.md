dotfiles
========

Your dotfiles are how you personalize your system. These are mine.

Note of caution for those that use, or try to use, these dotfiles: I use zsh,
followed by bash if zsh is not installed, as my shell. On systems where my shell is not
zsh, these dotfiles put me back to zsh when it is available.

install
=======

Run this:

```sh
git clone --recurse-submodules git@github.com:jdputsch/dotfiles.git
cd ~/.dotfiles
make
```

This will symlink the appropriate files in `.dotfiles` to your home directory.
Everything is configured and tweaked within `~/.dotfiles`.

The main file you'll want to change right off the bat is `zsh/zshrc
which sets up a few paths that'll be different on your particular machine.
