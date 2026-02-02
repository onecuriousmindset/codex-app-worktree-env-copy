#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────
# worktree-env: Copy .env files from your main project into
# Codex-created worktrees.
#
# The Codex macOS app creates isolated worktrees but doesn't
# trigger git hooks, so .env files never get copied over.
# This script bridges that gap — point it at your main project,
# and Codex's environment setup will handle the rest.
# ─────────────────────────────────────────────────────────────

# ⚠️  EDIT THIS: absolute path to your main project (the one with .env files)
MAIN_PROJECT="/path/to/your/project"

# ─────────────────── nothing to edit below ───────────────────

# Resolve the destination (the worktree Codex created).
if git rev-parse --show-toplevel >/dev/null 2>&1; then
  dest="$(git rev-parse --show-toplevel)"
else
  dest="$(pwd)"
fi

# Normalize paths
if command -v realpath >/dev/null 2>&1; then
  MAIN_PROJECT="$(realpath "$MAIN_PROJECT")"
  dest="$(realpath "$dest")"
fi

# Safety: don't copy onto ourselves
if [ "$MAIN_PROJECT" = "$dest" ]; then
  echo "worktree-env: source and destination are the same, nothing to copy."
  exit 0
fi

if [ ! -d "$MAIN_PROJECT" ]; then
  echo "worktree-env: source directory not found: $MAIN_PROJECT" >&2
  echo "worktree-env: edit MAIN_PROJECT in this script to point to your project." >&2
  exit 1
fi

copied=0

while IFS= read -r src_file; do
  rel_path="${src_file#"$MAIN_PROJECT"/}"
  dest_file="$dest/$rel_path"

  mkdir -p "$(dirname "$dest_file")"

  if [ ! -f "$dest_file" ]; then
    cp "$src_file" "$dest_file"
    echo "  copied: $rel_path"
    copied=$((copied + 1))
  fi
done < <(find "$MAIN_PROJECT" -name '.env*' -type f \
  -not -path '*/node_modules/*' \
  -not -path '*/.git/*' \
  -not -path '*/worktrees/*' \
  -not -path '*/.codex/*')

if [ "$copied" -eq 0 ]; then
  echo "worktree-env: all .env files already present."
else
  echo "worktree-env: copied $copied file(s)."
fi
