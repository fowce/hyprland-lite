# Oh My Zsh setup

ZSH_THEME="${ZSH_THEME:-gnzh}"
plugins=(git)

if [[ -r "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
fi
