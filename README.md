# dotfiles

Dotfiles managed with Git and GNU Stow.

Inspired by ["Using GNU Stow to manage your dotfiles"](http://brandon.invergo.net/news/2012-05-26-using-gnu-stow-to-manage-your-dotfiles.html).


## Process

1. Create a directory for each program (or other reasonable unit of division)
   that you want to configure.
2. Place the program's configuration files in the directory, preserving the
   directory structure of your home directory.
3. Run GNU Stow to symlink the appropriate files in your home directory.


### Example

Managing Git's `~/.gitconfig`:
```sh
# Importing an existing config file
> mkdir git
> mv ~/.gitconfig git

> tree -a 
.
└── git
    └── .gitconfig

# Link it to the appropriate place
> stow -vt ~ git
LINK: .gitconfig => dotfiles/git/.gitconfig

> ls -l ~/.gitconfig
lrwxrwxrwx 1 robin robin 23 Jan  6 16:01 /home/robin/.gitconfig -> dotfiles/git/.gitconfig
```
