#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
TOTAL_STEPS=4
STEP=0
START=$SECONDS
PROGRESS_NAMES=""   # file of dependency names; enables the x/N counter
PROGRESS_TOTAL=0

elapsed() {
  printf '%dm%02ds' $(( (SECONDS - START) / 60 )) $(( (SECONDS - START) % 60 ))
}

step_header() {
  STEP=$((STEP + 1))
  printf '\n[%d/%d] %s  (%s)\n' "$STEP" "$TOTAL_STEPS" "$1" "$(elapsed)"
}

# Drop ANSI colour codes plus the ^D / ^H that `script` echoes into the log.
strip_noise() {
  tr -d '\004\010' | sed -E "s/$(printf '\033')\\[[0-9;]*[A-Za-z]//g; s/\\^[DH]//g"
}

# Run a command under a pseudo-TTY (so it still sees a terminal and keeps its
# normal per-package output), keeping that output in a temp log while showing a
# live spinner with the current line, an optional x/N counter and elapsed time.
# The full log is dumped if the command fails.
run_step() {
  local label="$1"
  shift
  local log pid rc=0 frames="|/-\\" i=0 last counter="" done_n=0
  log="$(mktemp -t dotfiles-install)"
  if command -v script >/dev/null 2>&1; then
    script -q /dev/null "$@" >"$log" 2>&1 &
  else
    "$@" >"$log" 2>&1 &
  fi
  pid=$!
  while kill -0 "$pid" 2>/dev/null; do
    if [ -t 1 ]; then
      last="$(tail -n 1 "$log" 2>/dev/null | tr -d '\r' | strip_noise | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"
      [ -n "$last" ] || last="$label"
      if [ "$PROGRESS_TOTAL" -gt 0 ]; then
        done_n="$(strip_noise <"$log" | tr -d '\r' | sed -nE 's/^(Installing|Using) //p' | LC_ALL=C sort -u \
          | comm -12 - "$PROGRESS_NAMES" | wc -l | tr -d ' ')"
        counter="[$done_n/$PROGRESS_TOTAL] "
      fi
      printf '\r  %s %s%-44.44s %5ds' "${frames:i++%4:1}" "$counter" "$last" $((SECONDS - START))
    fi
    sleep 1
  done
  wait "$pid" || rc=$?
  if [ -t 1 ]; then
    printf '\r%*s\r' 78 ''
  fi
  if [ "$rc" -ne 0 ]; then
    echo "  ✗ $label — failed (exit $rc), full log: $log"
    tail -n 20 "$log" | strip_noise
    return "$rc"
  fi
  echo "  ✓ $label — $((SECONDS - START))s"
  rm -f "$log"
}

# 1. Install Homebrew if not present
step_header "Homebrew"
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
# Always wire Homebrew into PATH, not just after a fresh install: a brew that
# exists but is not exported would make the stow calls below fail under -e.
eval "$(/opt/homebrew/bin/brew shellenv)"

# 2. stow first (single small formula) so shell configs land before the long
#    package install, and survive a cask failure or an interrupted run.
step_header "stow packages"
run_step "brew install stow" brew install stow

cd "$DOTFILES_DIR"
packages=()
for dir in */; do
  dir="${dir%/}"
  case "$dir" in
    docs|.*) continue ;;
  esac
  packages+=("$dir")
done

# Dry-run first so existing files never leave a half-stowed state. GNU stow
# prints a "simulation mode" warning on every dry run; swallow that one line
# and only surface real conflicts.
echo "  checking for conflicts (dry run)..."
if ! dry_run="$(stow -n -t "$HOME" "${packages[@]}" 2>&1)"; then
  printf '%s\n' "$dry_run" | sed '/in simulation mode/d'
  echo
  echo "Stow found conflicting files in \$HOME (see above)."
  echo "Back them up or remove them, then re-run ./install.sh"
  exit 1
fi
echo "  no conflicts"

i=0
for pkg in "${packages[@]}"; do
  i=$((i + 1))
  printf '  [%d/%d] %s\n' "$i" "${#packages[@]}" "$pkg"
  stow -t "$HOME" "$pkg"
done

# 3. Install all packages via Brewfile. This is the slow step: ~70 formulae +
#    25 casks, several GB. Skip the update/upgrade pass so a re-run only
#    installs what is missing.
step_header "Brewfile packages (slow: ~70 formulae + 25 casks)"
PROGRESS_NAMES="$(mktemp -t dotfiles-names)"
brew bundle list --file="$DOTFILES_DIR/Brewfile" 2>/dev/null | LC_ALL=C sort -u >"$PROGRESS_NAMES" || true
PROGRESS_TOTAL="$(wc -l <"$PROGRESS_NAMES" | tr -d ' ')"
run_step "brew bundle" env HOMEBREW_NO_AUTO_UPDATE=1 \
  brew bundle --file="$DOTFILES_DIR/Brewfile" --no-upgrade
rm -f "$PROGRESS_NAMES"
PROGRESS_NAMES=""
PROGRESS_TOTAL=0

# 4. Create local (untracked) config from the example if missing
step_header "local config"
if [ ! -f "$HOME/.gitconfig.local" ] && [ -f "$DOTFILES_DIR/git/.gitconfig.local.example" ]; then
  cp "$DOTFILES_DIR/git/.gitconfig.local.example" "$HOME/.gitconfig.local"
  echo "  Created ~/.gitconfig.local - edit it with your name/email."
else
  echo "  ~/.gitconfig.local already present, left untouched."
fi

printf '\nDone in %s.\n' "$(elapsed)"
