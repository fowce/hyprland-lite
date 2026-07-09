# Repository-managed Zsh entrypoint.
#
# This file is intentionally minimal while the repository is under construction.
# It will be installed to ~/.zshrc only after the config is marked ready.

for file in "$HOME/.config/zsh/modules/"*.zsh; do
  [[ -r "$file" ]] && source "$file"
done

unset file
