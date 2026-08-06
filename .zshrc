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
__set_prompt() {
    local esc=$'\e'
    local reset="%{${esc}[0m%}"
    local c_text="%{${esc}[38;2;205;214;244m%}"
    local c_sky="%{${esc}[38;2;137;220;235m%}"
    local c_mauve="%{${esc}[38;2;202;158;230m%}"
    local c_red="%{${esc}[38;2;243;139;168m%}"
    local c_yellow="%{${esc}[38;2;249;226;175m%}"

    local git='' st head branch
    st=$(git status --porcelain -b 2>/dev/null)
    if [[ -n $st ]]; then
        head=${st%%$'\n'*}
        head=${head#'## '}
        branch=${head%%...*}
        branch=${branch//\%/%%}  # escape % so zsh does not treat it as a prompt token
        git=" ${c_mauve}${branch}${reset}"
        [[ $st == *$'\n'* ]] && git+=" ${c_red}!${reset} "
        [[ $head == *'ahead '* ]] && { local a=${head#*ahead }; git+=" ${c_yellow}↑ ${a%%[!0-9]*}${reset}"; }
        [[ $head == *'behind '* ]] && { local b=${head#*behind }; git+=" ${c_yellow}↓ ${b%%[!0-9]*}${reset}"; }
    fi

    PROMPT="${c_text}%n@%m${reset}:${c_sky}%~${reset}${git}%(#.#.$) ${reset}"
}
precmd_functions+=(__set_prompt)

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

# Disables vi-mode
bindkey -e

# prevent C-d terminating the shell
setopt ignore_eof 

# alias cat to bat (for color)
alias cat='bat -p --theme="Catppuccin-mocha"'

# if the term is "foot" (likely through ssh) then use a better common default
[[ $TERM == foot* ]] && export TERM=xterm-256color

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Switch node to the nearest .nvmrc on cd, and back to default when leaving one
autoload -U add-zsh-hook
load-nvmrc() {
  local nvmrc_path nvmrc_version
  nvmrc_path="$(nvm_find_nvmrc)"
  if [ -n "$nvmrc_path" ]; then
    nvmrc_version="$(nvm version "$(cat "$nvmrc_path")")"
    if [ "$nvmrc_version" = "N/A" ]; then
      nvm install # .nvmrc names a version that isn't installed yet
    elif [ "$nvmrc_version" != "$(nvm version)" ]; then
      nvm use --silent
    fi
  elif [ "$(nvm version)" != "$(nvm version default)" ]; then
    nvm use --silent default
  fi
  # brew shellenv (line 2) prepends /opt/homebrew/bin, which holds its own node, so force nvm's bin ahead of it
  [ -n "$NVM_BIN" ] && export PATH="$NVM_BIN:${PATH//:$NVM_BIN/}"
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc
