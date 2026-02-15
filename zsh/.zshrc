# load zgenom
source "${HOME}/.zgenom/zgenom.zsh"

export FZF_BASE=/opt/homebrew/opt/fzf/shell
# Check for plugin and zgenom updates every 7 days
# This does not increase the startup time.
# zgenom autoupdate

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
    zgenom ohmyzsh plugins/docker
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

    # add binaries

    # completions
    zgenom load zsh-users/zsh-completions

    # save all to init script
    zgenom save

    # Compile your zsh files
    zgenom compile "$HOME/.zshrc"
    # zgenom compile $ZDOTDIR

    # You can perform other "time consuming" maintenance tasks here as well.
    # If you use `zgenom autoupdate` you're making sure it gets
    # executed every 7 days.

    # rbenv rehash

    # ------ Homebrew ZSH functions (for just + others)
    # This will bring autocomplete for brew installed functions (exa, just, k6, etc)
    # These will overwrite the oh-my-zsh plugins that conflict (like `git`)
    # https://github.com/casey/just#shell-completion-scripts

    # Init Homebrew, which adds environment variables
    if command -v brew >/dev/null 2>&1; then
        eval "$(brew shellenv)"
    fi

    remove_conflicting_git_completions() {
        local git_completion_bash="$HOMEBREW_PREFIX/share/zsh/site-functions/git-completion.bash"
        local git_completion_zsh="$HOMEBREW_PREFIX/share/zsh/site-functions/_git"

        [ -e "$git_completion_bash" ] && rm "$git_completion_bash"
        [ -e "$git_completion_zsh" ] && rm "$git_completion_zsh"
    }

    # Delete the brew version of `git` completions because the built in ZSH
    # ones are objectively better (and work with aliases)
    # The reason this runs every time is because brew re-adds these files
    # on `brew upgrade` (and other events)
    remove_conflicting_git_completions

    # Add Homebrew's site functions to fpath (minus git, because that causes conflicts)
    # https://github.com/orgs/Homebrew/discussions/2797
    # https://github.com/ohmyzsh/ohmyzsh/issues/8037
    # https://github.com/ohmyzsh/ohmyzsh/issues/7062
    fpath=($HOMEBREW_PREFIX/share/zsh/site-functions $fpath)

    # Needed for autosuggestions (does compinit)
    source $ZSH/oh-my-zsh.sh
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

# Homebrew init
eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH=/opt/homebrew/bin:~/.local/bin:$PATH

# Python Local bin
# export PYENV_ROOT="$HOME/.pyenv"
# command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
# eval "$(pyenv init -)"

export LDFLAGS="-L/usr/local/opt/zlib/lib -L/usr/local/opt/bzip2/lib -L/opt/homebrew/opt/openblas/lib -L/opt/homebrew/opt/openssl@3/lib"
export CPPFLAGS="-I/usr/local/opt/zlib/include -I/usr/local/opt/bzip2/include -I/opt/homebrew/opt/openblas/include -I/opt/homebrew/opt/openssl@3/include"
export EDITOR=lvim

export C_INCLUDE_PATH=/opt/homebrew/opt/librdkafka/include
export LIBRARY_PATH=/opt/homebrew/opt/librdkafka/lib

# ~/.dircolors/themefile
# eval $(gdircolors ~/.dir_colors)

# Aliases
alias ls='lsd'
alias ll='ls -al'
alias lt='ls --tree'
alias lg='lazygit'

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# spark setting
# export JAVA_HOME="/Library/Java/JavaVirtualMachines/zulu-18.jdk/Contents/Home"

# starship
eval "$(starship init zsh)"

# jenv
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

# pipx
eval "$(register-python-argcomplete pipx)"

# tmsts
export PATH="/Users/zachary_lee/projects/tmsts/bin:$PATH"

# rye
source "$HOME/.rye/env"

export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  # [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# enrich completions
fpath+=~/.zfunc
FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
autoload -U compinit && compinit

# Added by Windsurf
export PATH="/Users/zachary_lee/.codeium/windsurf/bin:$PATH"
