#!/usr/bin/env bash
# Pull origin/main for this Neovim config, then install any new plugins.
set -euo pipefail
cd "$(dirname "$0")"

if ! command -v git >/dev/null 2>&1; then
  echo "git is required."
  exit 1
fi

if ! command -v nvim >/dev/null 2>&1; then
  echo "Install Neovim first, then re-run this script."
  exit 1
fi

git fetch origin
git pull --ff-only origin main

# Matches install.sh: download plugins from init.lua / lazy-lock.json.
nvim --headless "+Lazy! sync" +qa

echo "Config updated. Restart Neovim if it is already open."
