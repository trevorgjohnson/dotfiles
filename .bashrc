#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1='[\u@\h \W]\$ '
# . "$HOME/.cargo/env"

# Add ~/bin to PATH
export PATH=$PATH:/home/trevo/bin

# Set default `TERMINAL`
export TERMINAL="foot"

# Set default `EDITOR`
export EDITOR="nvim"

# Set the location of the obsidian vault
export VAULT=/home/trevo/Documents/eighth-ring-of-hell/

# Colorize man pages with bat
export MANPAGER="bat -plman"

# Stylize the shell
__set_prompt() {
    local reset='\[\e[0m\]'
    local c_text='\[\e[38;2;205;214;244m\]'
    local c_sky='\[\e[38;2;137;220;235m\]'
    local c_mauve='\[\e[38;2;202;158;230m\]'
    local c_red='\[\e[38;2;243;139;168m\]'
    local c_yellow='\[\e[38;2;249;226;175m\]'

    local git='' st head branch
    st=$(git status --porcelain -b 2>/dev/null)
    if [[ -n $st ]]; then
        head=${st%%$'\n'*}
        head=${head#'## '}
        branch=${head%%...*}
        git=" ${c_mauve}${branch}${reset}"
        [[ $st == *$'\n'* ]] && git+=" ${c_red}!${reset} "
        [[ $head == *'ahead '* ]] && { local a=${head#*ahead }; git+=" ${c_yellow}↑ ${a%%[!0-9]*}${reset}"; }
        [[ $head == *'behind '* ]] && { local b=${head#*behind }; git+=" ${c_yellow}↓ ${b%%[!0-9]*}${reset}"; }
    fi

    PS1="${c_text}\u@\h${reset}:${c_sky}\w${reset}${git}\\\$ ${reset}"
}
PROMPT_COMMAND=__set_prompt

# Add zoxide (or `z`) to a smarter cd
eval "$(zoxide init bash)"

# Force Wayland
export GDK_BACKEND=wayland,x11,*
export ELECTRON_OZONE_PLATFORM_HINT=wayland
export OZONE_PLATFORM=wayland
export XDG_SESSION_TYPE=wayland

# alias common unix cli tools with newer/modern alternatives
alias ls='ls --color=auto'
alias grep='rg --color=auto'
alias cat='bat -p --theme="Catppuccin Mocha"'
alias cd='z'

# add fzf to shell
eval "$(fzf --bash)"
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,spinner:#F5E0DC,hl:#F38BA8 \
--color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
--color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
--color=selected-bg:#45475A \
--color=border:#6C7086,label:#CDD6F4"
