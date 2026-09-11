# Neovim config

`init.lua` is the full setup: fuzzy search (Telescope), file tree, LSP, Copilot, and the rest. Plugin **source** is not copied into git — `install.sh` (or the first `nvim` launch) downloads it from the plugin list in `init.lua`, pinned by `lazy-lock.json`.

See [NEOVIM_SETUP.md](./NEOVIM_SETUP.md) for shortcuts.

Pick the section that matches your machine.

SSH clone (if you have GitHub SSH keys):

```bash
git clone git@github.com:utpalsinghdev/nvim-config.git ~/.config/nvim
```

HTTPS:

```bash
git clone https://github.com/utpalsinghdev/nvim-config.git ~/.config/nvim
```

---

## 1. First install (no Neovim yet)

macOS with Homebrew:

```bash
# Skip this line if brew already works.
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install neovim ripgrep fd
brew install --cask font-jetbrains-mono-nerd-font

git clone git@github.com:utpalsinghdev/nvim-config.git ~/.config/nvim
cd ~/.config/nvim
chmod +x install.sh
./install.sh
nvim
```

`install.sh` installs Neovim/ripgrep/fd if Homebrew is present, then runs a headless `Lazy sync`.

Set the terminal font to **JetBrainsMono Nerd Font**. Copilot: `:Copilot auth` once per machine.

Linux: install `neovim`, `ripgrep`, and `fd` from your package manager, then clone and run `./install.sh`.

---

## 2. New machine (Neovim already installed)

You already use Neovim, or this folder already exists:

```bash
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak 2>/dev/null || true

git clone git@github.com:utpalsinghdev/nvim-config.git ~/.config/nvim
cd ~/.config/nvim
chmod +x install.sh
./install.sh
nvim
```

`nvim.bak` is your old config. Keep it until you are sure this one is what you want.

---

## 3. Uninstall this config

Removes **this** setup (config + lazy plugins). Does **not** uninstall Homebrew Neovim.

```bash
rm -rf ~/.config/nvim
rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim
```

After this, `nvim` is the stock editor with no personal config.

To also remove Neovim itself on macOS:

```bash
brew uninstall neovim
```

---

## 4. Put your old config back

Use this after you tried this repo and want your previous Neovim back.

```bash
rm -rf ~/.config/nvim ~/.local/share/nvim
mv ~/.config/nvim.bak ~/.config/nvim
mv ~/.local/share/nvim.bak ~/.local/share/nvim 2>/dev/null || true
```

That only works if you created `.bak` folders in section 2. If you never backed up, there is nothing to restore — use section 3 and start a new config.

---

## Updates

The **↻** control at the far right of the statusline watches `origin/main`. When it turns red with a number, click it. Neovim pulls the config, installs new plugins, then asks you to quit so you can open Neovim again.
