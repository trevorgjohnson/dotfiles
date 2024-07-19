# homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# foundry
export PATH="$PATH:/Users/trevorjohnson/.foundry/bin"

# npm
export PATH="$PATH:/usr/local/bin"

# starship
eval "$(starship init zsh)"

# nvim
export EDITOR=nvim

# zsh autocomplete
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
bindkey "ç" fzf-cd-widget # For OSX, Alt-C outputs 'ç' which should use 'fzf-cd-widget' instead

# huff
export PATH="$PATH:/Users/trevorjohnson/.huff/bin"
. "$HOME/.cargo/env"
