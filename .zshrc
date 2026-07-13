# homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# foundry
export PATH="$PATH:/Users/trevorjohnson/.foundry/bin"

# npm
export PATH="$PATH:/usr/local/bin"

# dotfiles
export PATH="$PATH:$HOME/.config/dotfiles/bin"

# work scripts
export PATH="$PATH:$HOME/work_bin"

# Stylize the shell
source ./prompt.sh

# nvim
export EDITOR=nvim

# location of the obsidian vault
export VAULT=/Users/trevorjohnson/Documents/eighth-ring-of-hell/

# Colorize man pages with bat
export MANPAGER="bat -plman"

# zsh autocomplete and syntax highlighting
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# fzf
source <(fzf --zsh)
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,spinner:#F5E0DC,hl:#F38BA8 \
--color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
--color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
--color=selected-bg:#45475A \
--color=border:#6C7086,label:#CDD6F4"
bindkey "ç" fzf-cd-widget # For OSX, Alt-C outputs 'ç' which should use 'fzf-cd-widget' instead

# prevent C-d terminating the shell
setopt ignore_eof 

# alias cat to bat (for color)
alias cat='bat -p --theme="Catppuccin-mocha"'

# if the term is "foot" (likely through ssh) then use a better common default
[[ $TERM == foot* ]] && export TERM=xterm-256color

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
