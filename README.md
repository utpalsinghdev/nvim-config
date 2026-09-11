# Neovim config

Single-file config (`init.lua`) plus plugin lockfile. Plugins are installed on first launch by [lazy.nvim](https://github.com/folke/lazy.nvim); they live in Neovim's data directory, not in this repo.

See [NEOVIM_SETUP.md](./NEOVIM_SETUP.md) for plugins, shortcuts, and macOS packages.

## Install on a new machine

```bash
brew install neovim ripgrep fd
brew install --cask font-jetbrains-mono-nerd-font
```

Set the terminal font to **JetBrainsMono Nerd Font**.

If `~/.config/nvim` already exists, move it aside first:

```bash
mv ~/.config/nvim ~/.config/nvim.bak
git clone git@github.com:utpalsinghdev/nvim-config.git ~/.config/nvim
nvim
```

First launch clones plugins. Wait until lazy.nvim finishes, then restart Neovim once.

HTTPS clone if you do not use SSH:

```bash
git clone https://github.com/utpalsinghdev/nvim-config.git ~/.config/nvim
```

## What is not in this repo

- Plugin source (downloaded to `~/.local/share/nvim`)
- LSP servers installed by Mason (`~/.local/share/nvim/mason`)
- Undo history, swap, and local state
- Copilot / GitHub login (each machine authenticates itself)
