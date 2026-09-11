#!/usr/bin/env bash
# After cloning this repo into ~/.config/nvim, run: ./install.sh
set -euo pipefail

need() {
  command -v "$1" >/dev/null 2>&1
}

if [[ "$(uname -s)" == "Darwin" ]] && need brew; then
  brew install neovim ripgrep fd
  brew install --cask font-jetbrains-mono-nerd-font
fi

if ! need nvim; then
  echo "Install Neovim first, then re-run this script."
  exit 1
fi

if ! need fd && need fdfind; then
  mkdir -p "$HOME/.local/bin"
  ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
  export PATH="$HOME/.local/bin:$PATH"
fi

if ! need rg || ! need fd; then
  echo "Install ripgrep and fd (Debian: apt install ripgrep fd-find). Then re-run."
  exit 1
fi

if ! need make; then
  echo "Install a C compiler / make (macOS: xcode-select --install) for telescope-fzf-native."
  exit 1
fi

# Downloads every plugin in init.lua / lazy-lock.json, then quits.
nvim --headless "+Lazy! sync" +qa

echo "Plugins installed. Open Neovim with: nvim"
echo "Set the terminal font to JetBrainsMono Nerd Font if icons look wrong."
echo "Copilot: run :Copilot auth once per machine."
