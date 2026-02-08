#!/bin/bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [[ -L "$dst" ]]; then
    rm "$dst"
  elif [[ -e "$dst" ]]; then
    echo "  backing up $dst → ${dst}.bak"
    mv "$dst" "${dst}.bak"
  fi
  ln -s "$src" "$dst"
  echo "  $dst → $src"
}

echo "Installing dotfiles from $DOTFILES"
echo

link "$DOTFILES/zsh/zshrc"              "$HOME/.zshrc"
link "$DOTFILES/zsh/ghostty-colors.zsh" "$HOME/.config/ghostty-colors.zsh"
link "$DOTFILES/ghostty/config"         "$HOME/.config/ghostty/config"

# Create zshrc-local if it doesn't exist (machine-specific, not tracked)
if [[ ! -f "$HOME/.zshrc-local" ]]; then
  echo "# Machine-local zsh configuration (not version controlled)" > "$HOME/.zshrc-local"
  echo "  created ~/.zshrc-local (edit for local overrides)"
fi

echo
echo "Done. Restart your shell or run: source ~/.zshrc"
