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

if [[ -d "$BACKUP_DIR" ]]; then
  printf '\nPrevious configuration saved at: %s\n' "$BACKUP_DIR"
fi

printf '\nDone. Restart Claude Code or start a new session to load the configuration.\n'
