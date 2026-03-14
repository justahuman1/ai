#!/usr/bin/env bash
# Symlink public skills/docs from ~/.config/ai/ into ~/.claude/
# Safe to re-run — skips existing symlinks, replaces stale ones.

set -euo pipefail

SRC_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

# If ~/.claude/skills is a symlink (old all-or-nothing setup), remove it
if [ -L "$CLAUDE_DIR/skills" ]; then
  echo "Replacing old skills symlink with composed directory..."
  rm "$CLAUDE_DIR/skills"
fi

mkdir -p "$CLAUDE_DIR/skills"

link_dir() {
  local src="${1%/}" dest="$2" name
  name="$(basename "$src")"
  if [ -L "$dest" ]; then
    existing="$(readlink "$dest")"
    if [ "$existing" = "$src" ]; then
      echo "  $name — already linked"
      return
    fi
    echo "  $name — updating link"
    rm "$dest"
  elif [ -e "$dest" ]; then
    echo "  $name — skipping (real dir/file exists)"
    return
  fi
  ln -s "$src" "$dest"
  echo "  $name — linked"
}

# Skills
echo "Linking skills..."
for skill_dir in "$SRC_DIR"/skills/*/; do
  [ -d "$skill_dir" ] || continue
  link_dir "$skill_dir" "$CLAUDE_DIR/skills/$(basename "$skill_dir")"
done

# Docs subdirectories
if [ -d "$SRC_DIR/docs" ]; then
  mkdir -p "$CLAUDE_DIR/docs"
  echo "Linking docs..."
  for doc_dir in "$SRC_DIR"/docs/*/; do
    [ -d "$doc_dir" ] || continue
    link_dir "$doc_dir" "$CLAUDE_DIR/docs/$(basename "$doc_dir")"
  done
fi

echo "Done."
