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

# starship
eval "$(starship init zsh)"

# nvim
export EDITOR=nvim

# zsh autocomplete and syntax highlighting
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# fzf
source <(fzf --zsh)
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
bindkey "ç" fzf-cd-widget # For OSX, Alt-C outputs 'ç' which should use 'fzf-cd-widget' instead

# prevent C-d terminating the shell
setopt ignore_eof 

# Grep (specifically ripgrep) but it automatically ignores casing, files under autogen/library folders, and searches in hidden directories (eg. .github)
function g() {
  rg -i --hidden -g '!node_modules/' -g '!dist/' -g '!coverage/' -g '!artifacts/' -g '!broadcast/' -g '!cache*/' -g '!lib/' -g '!out/' $@
}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
