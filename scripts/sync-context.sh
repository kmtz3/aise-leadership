#!/usr/bin/env bash
# sync-context.sh — Pull the latest context/ from aise-assistant (the upstream source).
#
# context/ in this repo is sourced from kmtz3/aise-assistant. Never edit files in
# context/ directly here — all changes happen in aise-assistant and are synced here.
#
# Usage:
#   ./scripts/sync-context.sh        # sync and commit if context changed
#   ./scripts/sync-context.sh --dry  # show what would change, no writes

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"
DRY_RUN=false
[[ "${1:-}" == "--dry" ]] && DRY_RUN=true

cd "$PLUGIN_DIR"

# Ensure aise-assistant remote exists
if ! git remote get-url aise-assistant >/dev/null 2>&1; then
  git remote add aise-assistant https://github.com/kmtz3/aise-assistant.git
  echo "Added remote: aise-assistant"
fi

echo "Fetching aise-assistant/main..."
git fetch aise-assistant main --quiet

if $DRY_RUN; then
  echo "Changes that would be synced from aise-assistant/main:"
  git diff HEAD aise-assistant/main -- context/ || true
  exit 0
fi

# Check out context/ from aise-assistant/main into working tree
git checkout aise-assistant/main -- context/
git add context/

if git diff --cached --quiet; then
  echo "context/ already up to date with aise-assistant/main"
else
  git commit -m "sync: context/ from aise-assistant/main"
  echo "Synced and committed."
fi
