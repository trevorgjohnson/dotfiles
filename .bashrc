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

reset='\[\e[0m\]'
c_text='\[\e[38;2;205;214;244m\]'
c_sky='\[\e[38;2;137;220;235m\]'
c_mauve='\[\e[38;2;202;158;230m\]'
c_red='\[\e[38;2;243;139;168m\]'
c_yellow='\[\e[38;2;249;226;175m\]'
c_dim='\[\e[38;2;166;173;200m\]'

__git_prompt() {
    local branch status_lines out
    status_lines=$(git status --porcelain -b 2>/dev/null) || return

    # First line: "## main...origin/main [ahead 2]"
    branch="${status_lines%%$'\n'*}"
    branch="${branch#'## '}"
    branch="${branch%%...*}"

    out=" ${c_mauve}${branch}${reset}"

    # Dirty: any line beyond the header
    if [[ "$status_lines" == *$'\n'* ]]; then
        out+=" ${c_red}!${reset} "
    fi

    # Ahead/behind
    if [[ "$status_lines" =~ ahead\ ([0-9]+) ]]; then
        out+=" ${c_yellow}↑ ${BASH_REMATCH[1]}${reset}"
    fi
    if [[ "$status_lines" =~ behind\ ([0-9]+) ]]; then
        out+=" ${c_yellow}↓ ${BASH_REMATCH[1]}${reset}"
    fi

    printf '%s' "$out"
}

__set_prompt() {
    local git_info
    git_info=$(__git_prompt)
    PS1="${c_text}\u@\h${reset}:${c_sky}\w${reset}${git_info}\\\$ ${reset}"
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
