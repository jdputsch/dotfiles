dotfiles
========

Your dotfiles are how you personalize your system. These are mine.

The organization of my dotfiles is inspired by:

1. "holman does dotfiles":
    https://github.com/holman/dotfiles
    [his post on the subject](http://zachholman.com/2010/08/dotfiles-are-meant-to-be-forked/).
2. oh-my-zsh -- I use this for zshrc management, other zsh init files are here.
3. [Julien Voisin' .zshrc](https://dustri.org/b/my-zsh-configuration.html#my-zshrc)
4. [.dotzsh](https://github.com/dotphiles/dotzsh)

Note of caution for those that use, or try to use, these dotfiles: I use zsh as my shell. On systems where my shell is not zsh, these dotfiles put me back to zsh when it is available.

topical
=======

Everything's built around topic areas. If you're adding a new area to your
forked dotfiles — say, "Java" — you can simply add a java directory and put
files in there. Anything with an extension of .zsh will get automatically
included into your shell. Anything with an extension of .symlink will get
symlinked without extension into $HOME when you run script/bootstrap.

what's inside
=============

A lot of stuff. Check them out in the file browser above and see what components may mesh up with you.
[Fork it](https://bitbucket.analog.com/users/jputsch/repos/dotfiles?fork), remove what you don't use, and build on what you do use.

install
=======

Run this:

```sh
git clone ssh://git@bitbucket.analog.com:7999/~jputsch/dotfiles.git
cd ~/.dotfiles
script/bootstrap
```

This will symlink the appropriate files in `.dotfiles` to your home directory.
Everything is configured and tweaked within `~/.dotfiles`.

The main file you'll want to change right off the bat is `zsh/zshrc.symlink`,
which sets up a few paths that'll be different on your particular machine.

components
=========-
There are a few special files in the hierarchy:
  * topic/
    - topic/*.symlink: Any file ending in *.symlink gets symlinked into
                       your $HOME. This is so you can keep all of those
                       versioned in your dotfiles but still keep those
                       autoloaded files in your home directory. These
                       get symlinked in when you run script/bootstrap.

TODO: convert to a Make-based system, similar to: https://github.com/georgijd/dotfiles
