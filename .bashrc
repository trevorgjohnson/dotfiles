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

# Add starship for ~*_pretty-ness_*~
eval "$(starship init bash)"

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
alias cat='bat -p --color=auto'
alias cd='z'

# add fzf to shell
eval "$(fzf --bash)"
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8 \
--color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
--color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
--color=selected-bg:#45475A \
--color=border:#6C7086,label:#CDD6F4"
