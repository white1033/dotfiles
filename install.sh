#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# 1. Install Homebrew if not present
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# 2. Install all packages via Brewfile (includes stow)
brew bundle --file="$DOTFILES_DIR/Brewfile"

# 3. Collect stow packages (every top-level dir except non-package ones)
cd "$DOTFILES_DIR"
packages=()
for dir in */; do
  dir="${dir%/}"
  case "$dir" in
    docs|.*) continue ;;
  esac
  packages+=("$dir")
done

# 4. Dry-run first so existing files never leave a half-stowed state
if ! stow -n -t "$HOME" "${packages[@]}"; then
  echo
  echo "Stow found conflicting files in \$HOME (see above)."
  echo "Back them up or remove them, then re-run ./install.sh"
  exit 1
fi

for pkg in "${packages[@]}"; do
  echo "Stowing $pkg..."
  stow -v -t "$HOME" "$pkg"
done

# 5. Create local (untracked) config from the example if missing
if [ ! -f "$HOME/.gitconfig.local" ] && [ -f "$DOTFILES_DIR/git/.gitconfig.local.example" ]; then
  cp "$DOTFILES_DIR/git/.gitconfig.local.example" "$HOME/.gitconfig.local"
  echo "Created ~/.gitconfig.local - edit it with your name/email."
fi

echo "Done!"
