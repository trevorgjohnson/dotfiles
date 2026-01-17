#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1='[\u@\h \W]\$ '
. "$HOME/.cargo/env"

# Set default `TERMINAL` to `ghostty`
export TERMINAL="ghostty"

# Add ~/bin to the list of binary paths under $PATH
export PATH="${PATH}:${HOME}/bin"

# Add starship for ~*_pretty-ness_*~
eval "$(starship init bash)"

# Add zoxide (or `z`) to a smarter cd
eval "$(zoxide init bash)"

# alias common unix cli tools with newer/modern alternatives
alias ls='exa --color=auto'
alias grep='rg --color=auto'
alias find='fd --color=auto'
alias cat='bat --color=auto'
alias cd='z'

# add fzf to shell
eval "$(fzf --bash)"
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8 \
--color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
--color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
--color=selected-bg:#45475A \
--color=border:#6C7086,label:#CDD6F4"
