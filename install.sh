#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
BACKUP_DIR="$CLAUDE_DIR/backups/claude-skills-$(date +%Y%m%d-%H%M%S)-$$"

install_link() {
  local source="$1" target="$2"
  mkdir -p -- "$(dirname -- "$target")"

  if [[ -L "$target" ]] && [[ "$(readlink -- "$target")" == "$source" ]]; then
    printf 'Already linked: %s\n' "$target"
    return
  fi

  if [[ -e "$target" || -L "$target" ]]; then
    mkdir -p -- "$BACKUP_DIR"
    local relative="${target#"$CLAUDE_DIR"/}"
    mkdir -p -- "$(dirname -- "$BACKUP_DIR/$relative")"
    mv -- "$target" "$BACKUP_DIR/$relative"
    printf 'Backed up: %s\n' "$target"
  fi

  ln -s -- "$source" "$target"
  printf 'Linked: %s -> %s\n' "$target" "$source"
}

install_link "$REPO_DIR/config/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
install_link "$REPO_DIR/config/agents/Explore.md" "$CLAUDE_DIR/agents/Explore.md"
install_link "$REPO_DIR/config/statusline-command.sh" "$CLAUDE_DIR/statusline-command.sh"

# Review plugins share their saved model/effort preferences.
# Set sensible initial defaults without clobbering existing user choices.
REVIEW_PREF_DIR="$CLAUDE_DIR/przeglad-petla"
mkdir -p -- "$REVIEW_PREF_DIR"

if [[ ! -e "$REVIEW_PREF_DIR/model" && ! -L "$REVIEW_PREF_DIR/model" ]]; then
  printf 'opus\n' > "$REVIEW_PREF_DIR/model"
  printf 'Initialized review model: opus\n'
fi
if [[ ! -e "$REVIEW_PREF_DIR/poziom" && ! -L "$REVIEW_PREF_DIR/poziom" ]]; then
  printf 'medium\n' > "$REVIEW_PREF_DIR/poziom"
  printf 'Initialized review effort: medium\n'
fi

if [[ -d "$BACKUP_DIR" ]]; then
  printf '\nPrevious configuration saved at: %s\n' "$BACKUP_DIR"
fi

printf '\nDone. Restart Claude Code or start a new session to load the configuration.\n'
