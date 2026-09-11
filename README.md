# Neovim config

`init.lua` is the full setup: fuzzy search (Telescope), file tree, LSP, Copilot, and the rest. Plugin **source** is not copied into git — `install.sh` (or the first `nvim` launch) downloads it from the plugin list in `init.lua`, pinned by `lazy-lock.json`.

See [NEOVIM_SETUP.md](./NEOVIM_SETUP.md) for shortcuts.

## New machine (clone + one install)

```bash
mv ~/.config/nvim ~/.config/nvim.bak   # only if that folder already exists
git clone git@github.com:utpalsinghdev/nvim-config.git ~/.config/nvim
cd ~/.config/nvim
chmod +x install.sh
./install.sh
nvim
```

`install.sh` installs Neovim, ripgrep, and fd on macOS (Homebrew), then runs a headless `Lazy sync` so every plugin is on disk before you open the editor.

Set the terminal font to **JetBrainsMono Nerd Font**. Copilot still needs `:Copilot auth` once per machine.

HTTPS:

```bash
git clone https://github.com/utpalsinghdev/nvim-config.git ~/.config/nvim
```
