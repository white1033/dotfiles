# OPENSPEC:START
# OpenSpec shell completions configuration
fpath=("/Users/zachary_lee/.zsh/completions" $fpath)
autoload -Uz compinit
compinit
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

# Alias
alias lg='lazygit'
alias rm='safe-rm'

# Load and initialise completion system
autoload -Uz compinit
compinit -d "${ZDOTDIR:-$HOME}/.zcompdump"

# fzf-tab 必須在 compinit 之後
plug "Aloxaf/fzf-tab"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/zachary_lee/.cache/lm-studio/bin"

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
export PATH="/Users/zachary_lee/.antigravity/antigravity/bin:$PATH"

# bun completions
[ -s "/Users/zachary_lee/.bun/_bun" ] && source "/Users/zachary_lee/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

