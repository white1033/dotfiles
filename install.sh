#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# 1. Install Homebrew if not present
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# 2. Install stow
brew install stow

# 3. Install all packages via Brewfile
brew bundle --file="$DOTFILES_DIR/Brewfile"

# 4. Stow all packages
cd "$DOTFILES_DIR"
for dir in */; do
  case "$dir" in
    docs/|.git/|.claude/) continue ;;
  esac
  echo "Stowing $dir..."
  stow -v -t "$HOME" "$dir"
done

echo "Done!"
