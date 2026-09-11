# Neovim config

`init.lua` is the full setup: fuzzy search (Telescope), file tree, LSP, Copilot, and the rest. Plugin **source** is not copied into git — `install.sh` (or the first `nvim` launch) downloads it from the plugin list in `init.lua`, pinned by `lazy-lock.json`.

See [NEOVIM_SETUP.md](./NEOVIM_SETUP.md) for shortcuts.

**Needs Neovim 0.10+.** After install, set the terminal font to **JetBrainsMono Nerd Font** and run `:Copilot auth` once.

## Jump to your machine

| Machine | First install (no Neovim) | Already have Neovim | Uninstall | Old config back |
|---------|---------------------------|---------------------|-----------|-----------------|
| [macOS](#macos) | [install](#macos-first-install) | [swap in](#macos-already-have-neovim) | [uninstall](#macos-uninstall) | [restore](#macos-restore) |
| [Windows](#windows) | [install](#windows-first-install) | [swap in](#windows-already-have-neovim) | [uninstall](#windows-uninstall) | [restore](#windows-restore) |
| [Debian / Ubuntu](#debian--ubuntu) | [install](#debian-first-install) | [swap in](#debian-already-have-neovim) | [uninstall](#debian-uninstall) | [restore](#debian-restore) |
| [Fedora](#fedora) | [install](#fedora-first-install) | [swap in](#fedora-already-have-neovim) | [uninstall](#fedora-uninstall) | [restore](#fedora-restore) |

Clone URLs (used in every install):

```bash
# SSH
git clone git@github.com:utpalsinghdev/nvim-config.git ~/.config/nvim

# HTTPS
git clone https://github.com/utpalsinghdev/nvim-config.git ~/.config/nvim
```

On Windows PowerShell, the clone target is `$env:LOCALAPPDATA\nvim` (see below).

`git clone … ~/.config/nvim` **fails** if that folder already exists (`fatal: destination path … already exists`). Fedora, Debian, and macOS often create an empty or leftover `~/.config/nvim` the first time you open Neovim. First-install steps below move it to `nvim.bak` before cloning. If `nvim.bak` is already there, rename it first.

---

## macOS

Needs Homebrew, Git, and a compiler (`xcode-select --install` if `make` is missing).

### macOS first install

```bash
# Skip if brew already works.
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install neovim ripgrep fd git
brew install --cask font-jetbrains-mono-nerd-font
xcode-select --install 2>/dev/null || true

# Leftover folder is common even on a "new" machine.
[ -e ~/.config/nvim ] && mv ~/.config/nvim ~/.config/nvim.bak
[ -e ~/.local/share/nvim ] && mv ~/.local/share/nvim ~/.local/share/nvim.bak

git clone git@github.com:utpalsinghdev/nvim-config.git ~/.config/nvim
cd ~/.config/nvim
chmod +x install.sh
./install.sh
nvim
```

### macOS already have Neovim

```bash
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak 2>/dev/null || true

git clone git@github.com:utpalsinghdev/nvim-config.git ~/.config/nvim
cd ~/.config/nvim
chmod +x install.sh
./install.sh
nvim
```

Keep the `.bak` folders until you are sure.

### macOS uninstall

Removes this config and plugin cache. Neovim stays installed.

```bash
rm -rf ~/.config/nvim ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim
```

To remove Neovim itself:

```bash
brew uninstall neovim
```

### macOS restore

```bash
rm -rf ~/.config/nvim ~/.local/share/nvim
mv ~/.config/nvim.bak ~/.config/nvim
mv ~/.local/share/nvim.bak ~/.local/share/nvim 2>/dev/null || true
```

---

## Windows

Use **PowerShell**. Config lives in `%LOCALAPPDATA%\nvim`, plugins in `%LOCALAPPDATA%\nvim-data`.

Install [Git for Windows](https://git-scm.com/download/win) if `git` is missing. Font: download **JetBrainsMono Nerd Font** from [Nerd Fonts](https://www.nerdfonts.com/font-downloads) and set it in Windows Terminal.

### Windows first install

```powershell
winget install --id Git.Git -e
winget install --id Neovim.Neovim -e
winget install --id BurntSushi.ripgrep.MSVC -e
winget install --id sharkdp.fd -e

if (Test-Path $env:LOCALAPPDATA\nvim) { Move-Item $env:LOCALAPPDATA\nvim $env:LOCALAPPDATA\nvim.bak }
if (Test-Path $env:LOCALAPPDATA\nvim-data) { Move-Item $env:LOCALAPPDATA\nvim-data $env:LOCALAPPDATA\nvim-data.bak }

git clone git@github.com:utpalsinghdev/nvim-config.git $env:LOCALAPPDATA\nvim
nvim --headless "+Lazy! sync" +qa
nvim
```

HTTPS clone if you do not use SSH:

```powershell
git clone https://github.com/utpalsinghdev/nvim-config.git $env:LOCALAPPDATA\nvim
```

`install.sh` is for macOS/Linux. On Windows the `nvim --headless "+Lazy! sync" +qa` line is the plugin install.

### Windows already have Neovim

```powershell
if (Test-Path $env:LOCALAPPDATA\nvim) { Move-Item $env:LOCALAPPDATA\nvim $env:LOCALAPPDATA\nvim.bak }
if (Test-Path $env:LOCALAPPDATA\nvim-data) { Move-Item $env:LOCALAPPDATA\nvim-data $env:LOCALAPPDATA\nvim-data.bak }

git clone git@github.com:utpalsinghdev/nvim-config.git $env:LOCALAPPDATA\nvim
nvim --headless "+Lazy! sync" +qa
nvim
```

### Windows uninstall

```powershell
Remove-Item -Recurse -Force $env:LOCALAPPDATA\nvim, $env:LOCALAPPDATA\nvim-data -ErrorAction SilentlyContinue
```

To remove Neovim itself:

```powershell
winget uninstall Neovim.Neovim
```

### Windows restore

```powershell
Remove-Item -Recurse -Force $env:LOCALAPPDATA\nvim, $env:LOCALAPPDATA\nvim-data -ErrorAction SilentlyContinue
if (Test-Path $env:LOCALAPPDATA\nvim.bak) { Move-Item $env:LOCALAPPDATA\nvim.bak $env:LOCALAPPDATA\nvim }
if (Test-Path $env:LOCALAPPDATA\nvim-data.bak) { Move-Item $env:LOCALAPPDATA\nvim-data.bak $env:LOCALAPPDATA\nvim-data }
```

---

## Debian / Ubuntu

Package name for fd is `fd-find`; the binary is `fdfind`. The commands below make a `fd` shortcut. If `nvim --version` is older than 0.10, install a [newer Neovim](https://github.com/neovim/neovim/releases) before cloning.

Font: install **JetBrainsMono Nerd Font** from [Nerd Fonts](https://www.nerdfonts.com/font-downloads) and set it in the terminal.

### Debian first install

```bash
sudo apt update
sudo apt install -y git neovim ripgrep fd-find make gcc unzip curl

mkdir -p ~/.local/bin
ln -sf "$(command -v fdfind)" ~/.local/bin/fd
export PATH="$HOME/.local/bin:$PATH"

[ -e ~/.config/nvim ] && mv ~/.config/nvim ~/.config/nvim.bak
[ -e ~/.local/share/nvim ] && mv ~/.local/share/nvim ~/.local/share/nvim.bak

git clone git@github.com:utpalsinghdev/nvim-config.git ~/.config/nvim
cd ~/.config/nvim
chmod +x install.sh
./install.sh
nvim
```

### Debian already have Neovim

```bash
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak 2>/dev/null || true

git clone git@github.com:utpalsinghdev/nvim-config.git ~/.config/nvim
cd ~/.config/nvim
chmod +x install.sh
./install.sh
nvim
```

### Debian uninstall

```bash
rm -rf ~/.config/nvim ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim
```

To remove Neovim itself:

```bash
sudo apt remove neovim
```

### Debian restore

```bash
rm -rf ~/.config/nvim ~/.local/share/nvim
mv ~/.config/nvim.bak ~/.config/nvim
mv ~/.local/share/nvim.bak ~/.local/share/nvim 2>/dev/null || true
```

---

## Fedora

```bash
sudo dnf install -y git neovim ripgrep fd-find make gcc unzip
```

On Fedora the `fd-find` package usually provides `fd`. If `fd` is missing: `ln -sf "$(command -v fdfind)" ~/.local/bin/fd`.

Font: [JetBrainsMono Nerd Font](https://www.nerdfonts.com/font-downloads).

### Fedora first install

```bash
sudo dnf install -y git neovim ripgrep fd-find make gcc unzip

[ -e ~/.config/nvim ] && mv ~/.config/nvim ~/.config/nvim.bak
[ -e ~/.local/share/nvim ] && mv ~/.local/share/nvim ~/.local/share/nvim.bak

git clone git@github.com:utpalsinghdev/nvim-config.git ~/.config/nvim
cd ~/.config/nvim
chmod +x install.sh
./install.sh
nvim
```

### Fedora already have Neovim

```bash
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak 2>/dev/null || true

git clone git@github.com:utpalsinghdev/nvim-config.git ~/.config/nvim
cd ~/.config/nvim
chmod +x install.sh
./install.sh
nvim
```

### Fedora uninstall

```bash
rm -rf ~/.config/nvim ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim
```

To remove Neovim itself:

```bash
sudo dnf remove neovim
```

### Fedora restore

```bash
rm -rf ~/.config/nvim ~/.local/share/nvim
mv ~/.config/nvim.bak ~/.config/nvim
mv ~/.local/share/nvim.bak ~/.local/share/nvim 2>/dev/null || true
```

---

## Updates

The **↻** control at the far right of the statusline watches `origin/main`. When it turns red with a number, click it. Neovim pulls the config, installs new plugins, then asks you to quit so you can open Neovim again.
