# load zgenom
source "${HOME}/.zgenom/zgenom.zsh"

# Check for plugin and zgenom updates every 7 days
# This does not increase the startup time.
zgenom autoupdate

# if the init script doesn't exist
if ! zgenom saved; then
    echo "Creating a zgenom save"

    # Ohmyzsh base library
    zgenom ohmyzsh

    # You can also cherry pick just parts of the base library.
    # Not loading the base set of ohmyzsh libraries might lead to issues.
    # While you can do it, I won't recommend it unless you know how to fix
    # those issues yourself.

    # Remove `zgenom ohmyzsh` and load parts of ohmyzsh like this:
    # `zgenom ohmyzsh path/to/file.zsh`
    # zgenom ohmyzsh lib/git.zsh # load git library of ohmyzsh

    # plugins
    zgenom ohmyzsh plugins/git
    zgenom ohmyzsh plugins/sudo
    zgenom ohmyzsh plugins/fzf
    zgenom ohmyzsh plugins/rust
    # just load the completions
    zgenom ohmyzsh --completion plugins/docker-compose

    # Install ohmyzsh osx plugin if on macOS
    [[ "$(uname -s)" = Darwin ]] && zgenom ohmyzsh plugins/macos

    # prezto options
    zgenom prezto editor key-bindings 'emacs'

    # prezto and modules
    # If you use prezto and ohmyzsh - load ohmyzsh first.
    zgenom prezto
    zgenom prezto command-not-found

    # Load prezto tmux when tmux is installed
    if hash tmux &>/dev/null; then
        zgenom prezto tmux
    fi

    zgenom load zdharma-continuum/fast-syntax-highlighting
    zgenom load zsh-users/zsh-autosuggestions
    zgenom load zsh-users/zsh-history-substring-search
EOPLUGINS
    # ^ can't indent this EOPLUGINS

    # add binaries
    zgenom bin tj/git-extras

    # completions
    zgenom load zsh-users/zsh-completions

    # save all to init script
    zgenom save

    # Compile your zsh files
    zgenom compile "$HOME/.zshrc"
    zgenom compile $ZDOTDIR

    # You can perform other "time consuming" maintenance tasks here as well.
    # If you use `zgenom autoupdate` you're making sure it gets
    # executed every 7 days.

    # rbenv rehash
fi
# enable the color support of ls {{{
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors \
        && eval "$(dircolors -b ~/.dircolors)" \
        || eval "$(dircolors -b)"
    alias ls='ls --quoting-style=literal --color=auto'
fi
# }}}


# Enable fzf
if [ -f ~/.fzf.zsh ]; then
    source ~/.fzf.zsh
fi
# }}}


# Python Local bin
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"

# Load pyenv into the shell by adding
# the following to ~/.zshrc:

eval "$(pyenv init -)"
export LDFLAGS="-L/usr/local/opt/zlib/lib -L/usr/local/opt/bzip2/lib"
export CPPFLAGS="-I/usr/local/opt/zlib/include -I/usr/local/opt/bzip2/include"

export EDITOR=nvim

# ~/.dircolors/themefile
eval $(gdircolors ~/.dir_colors)

# Aliases
alias ls='gls --quoting-style=literal --color=auto'
alias ll='ls -al'

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# spark setting
# export JAVA_HOME=`/usr/libexec/java_home`
export JAVA_HOME="/Library/Java/JavaVirtualMachines/adoptopenjdk-11.jdk/Contents/Home"

eval "$(starship init zsh)"
