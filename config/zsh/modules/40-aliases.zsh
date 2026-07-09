# General aliases

alias ..='cd ..'
alias c='clear'
alias nf='fastfetch'
alias pf='fastfetch'
alias ff='fastfetch'
alias wifi='nmtui'
alias lock='hyprlock'
alias v='$EDITOR'
alias vim='$EDITOR'

if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons=always --group-directories-first'
  alias ll='eza -la --icons=always --group-directories-first'
  alias la='eza -a --icons=always --group-directories-first'
  alias lt='eza --tree --level=2 --icons=always --group-directories-first'
else
  alias ls='ls --color=auto'
  alias ll='ls -la --color=auto'
  alias la='ls -A --color=auto'
fi

alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gpl='git pull'
alias gst='git stash'
alias gfo='git fetch origin'
