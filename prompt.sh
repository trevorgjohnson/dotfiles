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
