typeset -U path

# Cache the output of slow init commands; regenerate when the binary is newer than the cache
_cached_eval() {
  local name=$1 bin=$2; shift 2
  local cache="$HOME/.cache/zsh/$name.zsh"
  # No binary (not installed yet) -> nothing to cache, nothing to source.
  [[ -n $bin ]] || return 0
  # ~/.cache/zsh does not exist on a fresh macOS account; without this the
  # redirect below fails and `source` errors on every new shell.
  mkdir -p "${cache:h}"
  if [[ ! -s $cache || $bin -nt $cache ]]; then
    "$bin" "$@" >| "$cache" 2>/dev/null
  fi
  if [[ -s $cache ]]; then
    source "$cache"
  else
    eval "$("$bin" "$@")"   # cache unwritable: run the command directly
  fi
}

# Homebrew (must come first so all brew-installed tools are in PATH)
_cached_eval brew-shellenv /opt/homebrew/bin/brew shellenv

# fpath (all additions must come before compinit)
fpath=("$HOME/.zsh/completions" $fpath)   # OPENSPEC
fpath=($HOMEBREW_PREFIX/share/zsh/site-functions $fpath)
fpath+=~/.zfunc

# compinit is handled by the zap-zsh/supercharge plugin (fpath must be set above)

# Alias
alias lg='lazygit'
alias rm='safe-rm'

# Zap plugins
[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"
plug "zsh-users/zsh-autosuggestions"
plug "zap-zsh/supercharge"
source <(fzf --zsh)
# fzf-tab 必須在 compinit 之後，且在 syntax-highlighting 之前
plug "Aloxaf/fzf-tab"
# zsh-syntax-highlighting 必須放在最後
plug "zsh-users/zsh-syntax-highlighting"

# History (after supercharge, which sets its own values)
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY EXTENDED_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS

# eza (must come after supercharge, which sets ls='ls -G')
alias ls='eza --group-directories-first --icons=auto'
alias ll='ls -lh --git'
alias la='ll -a'
alias tree='ll --tree --level=2'

# fzf
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_DEFAULT_OPTS='
  --height 40%
  --layout reverse
  --border
  --color=bg+:#363a4f,bg:#24273a,spinner:#f4dbd6,hl:#ed8796
  --color=fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6
  --color=marker:#b7bdf8,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796
  --color=selected-bg:#494d64
'
export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always {}' --bind 'ctrl-/:change-preview-window(down|hidden|)'"

export EDITOR=nvim

# yazi
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# zoxide
eval "$(zoxide init zsh)"

# PATH additions
export GOPATH=$HOME/go
export BUN_INSTALL="$HOME/.bun"
export PATH=$GOPATH/bin:$BUN_INSTALL/bin:$HOME/.antigravity/antigravity/bin:$HOME/.omlx/bin:$HOME/.local/bin:$PATH
export PATH="$PATH:$HOME/.cache/lm-studio/bin"   # Added by LM Studio CLI (lms)

# Load environment variables from ~/.env
if [ -f ~/.env ]; then
  set -a
  source ~/.env
  set +a
fi

# Source local secrets last so they override values from ~/.env
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Starship prompt
eval "$(starship init zsh)"

# oMP: Oh My Pi shell completion (cached)
_cached_eval omp-completions "$(command -v omp)" completions zsh

# Deduplicate PATH (export PATH=... string assignments bypass typeset -U, so re-assign the array last)
path=($path)
