# OPENSPEC:START
# OpenSpec shell completions configuration
fpath=("$HOME/.zsh/completions" $fpath)
# OPENSPEC:END

# Created by Zap installer
[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"
plug "zsh-users/zsh-autosuggestions"
plug "zap-zsh/supercharge"
plug "MAHcodes/distro-prompt"
plug "wintermi/zsh-brew"
plug "MichaelAquilina/zsh-you-should-use"
plug "zap-zsh/exa"
plug "zap-zsh/fzf"
plug "zsh-users/zsh-syntax-highlighting"  # 應該在最後

# Add Homebrew's site functions to fpath (minus git, because that causes conflicts)
fpath=($HOMEBREW_PREFIX/share/zsh/site-functions $fpath)

# Add self completion
fpath+=~/.zfunc

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY

# Alias
alias lg='lazygit'
alias rm='safe-rm'

# Load and initialise completion system
autoload -Uz compinit
compinit -d "${ZDOTDIR:-$HOME}/.zcompdump"

# fzf-tab 必須在 compinit 之後
plug "Aloxaf/fzf-tab"

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

# Added by LM Studio CLI (lms)
export PATH="$PATH:$HOME/.cache/lm-studio/bin"

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

# Golang environment variables
export GOROOT=/opt/homebrew/opt/go/libexec
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$GOROOT/bin:$HOME/.local/bin:$PATH

# Source local secrets (API keys, tokens, etc.) — not tracked by git
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# Added by Antigravity
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export EDITOR=nvim
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Deduplicate PATH entries
typeset -U path

