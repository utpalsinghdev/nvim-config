# Neovim Setup

## Installation

```bash
brew install neovim ripgrep fd
brew install --cask font-jetbrains-mono-nerd-font
```

- **neovim 0.12.3** — editor
- **ripgrep** — required for grep across files (Telescope live_grep)
- **fd** — required for fast file finding (Telescope find_files)
- **JetBrainsMono Nerd Font** — required for file/folder icons

> Set your terminal font to `JetBrainsMono Nerd Font` in terminal Preferences → Profile → Font

---

## Config Location

```
~/.config/nvim/init.lua
```

---

## Plugins Installed

| Plugin | Purpose |
|--------|---------|
| catppuccin/nvim | Colorscheme (mocha, transparent background) |
| nvim-treesitter | Syntax highlighting |
| nvim-tree.lua | File tree (like VSCode sidebar) |
| telescope.nvim | Fuzzy finder (files, grep, buffer search) |
| telescope-fzf-native | Faster fuzzy matching |
| mini.animate | Smooth cursor, scroll, window animations |
| noice.nvim | Fancy command line + UI effects |
| nvim-notify | Animated notifications |
| lualine.nvim | Statusline at the bottom |
| bufferline.nvim | Buffer tabs at the top (like VSCode tabs) |
| which-key.nvim | Popup shortcut guide (press Space and wait) |
| indent-blankline.nvim | Indent guide lines |
| gitsigns.nvim | Git changes in the gutter |
| vim-fugitive | Git commands (`:Git blame -w`) |
| nvim-autopairs | Auto-close brackets/quotes |
| Comment.nvim | Toggle comments |
| rainbow-delimiters.nvim | Colorized matching brackets |
| flash.nvim | Jump anywhere on screen with 2 keystrokes |
| dashboard-nvim | Start screen |
| neominimap.nvim | Right-side file minimap (braille dots, errors, current line) |
| mason.nvim | LSP server installer UI (`:Mason` to open) |
| mason-lspconfig.nvim | Auto-installs LSP servers via Mason |
| nvim-lspconfig | Configures language servers (includes ESLint for JS/TS) |
| nvim-cmp | Autocomplete popup (also filters `:` commands as you type) |
| LuaSnip | Snippet engine |
| conform.nvim | Auto-format on save |
| copilot.lua | GitHub Copilot inline tab suggestions |

---

## Shortcuts

### Modes

| Key | Mode |
|-----|------|
| `Esc` | Back to Normal mode (shortcuts work here) |
| `i` | Insert mode (for typing) |
| `v` | Visual mode (select characters) |
| `V` | Visual Line mode (select whole lines) |
| `Ctrl+v` | Visual Block mode (column select) |

### VSCode-style Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+P` | Find file by name |
| `Space + e` | Toggle file tree |
| `Ctrl+F` / `Space + /` | Search in current file |
| `Ctrl+Shift+F` / `Space + fg` | Grep across all files |
| `Ctrl+S` | Save file |
| `Esc` | Leave insert mode (also saves the file) |
| `Ctrl+A` | Select all |
| `Ctrl+W` | Close buffer |
| `Alt+J` / `Alt+K` | Move line down / up |
| `Ctrl+/` | Toggle comment |
| `Space + gb` / `:GitBlame` | Git blame (file must be in a git repo) |

> File tree is `Space+e`, not `Ctrl+B` — `Ctrl+B` is Herdr's prefix.

### File Tree (Space+E to open)

| Key | Action |
|-----|--------|
| `l` or Enter | Open file / expand folder |
| `h` | Collapse folder |
| `a` | New file |
| `d` | Delete |
| `r` | Rename |
| `R` | Refresh |

### Buffer (Tab) Navigation

| Key | Action |
|-----|--------|
| `Shift+L` | Next buffer (tab right) |
| `Shift+H` | Previous buffer (tab left) |
| `Space+b` | Pick open buffer with Telescope |
| `Ctrl+W` | Close buffer |

### Window Splits

| Key | Action |
|-----|--------|
| `Space+sv` | Split vertical |
| `Space+sh` | Split horizontal |
| `Ctrl+H/J/K/L` | Move between splits |

### Movement

| Key | Action |
|-----|--------|
| `h j k l` | Left / Down / Up / Right |
| `w` / `b` | Jump word forward / backward |
| `0` / `$` | Start / End of line |
| `gg` / `G` | Top / Bottom of file |
| `Ctrl+d` / `Ctrl+u` | Half page down / up |
| `s` | Flash jump — type 2 chars to teleport anywhere on screen |

### Editing

| Key | Action |
|-----|--------|
| `dd` | Cut line |
| `yy` | Copy line |
| `p` / `P` | Paste below / above |
| `u` | Undo |
| `Ctrl+R` | Redo |
| `ciw` | Change inner word |
| `di"` | Delete inside quotes |
| `.` | Repeat last action |
| `Space+d` | Duplicate line |
| `Space+o` | New line below (stay in normal mode) |

### Multi-line / Multi-select

| Key | Action |
|-----|--------|
| `V` then `j/k` | Select multiple lines |
| `Ctrl+v` then `j/k` then `I` | Column insert (multi-cursor style) |
| `gc` (in visual) | Comment selected lines |
| `>` / `<` (in visual) | Indent / Dedent selection |

### Search & Replace

| Key | Action |
|-----|--------|
| `/word` Enter | Search forward |
| `n` / `N` | Next / Previous match |
| `Esc` | Clear search highlights |
| `:%s/old/new/g` | Replace all in file |

### LSP (works inside any code file)

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Show all references |
| `K` | Hover docs (show type/signature) |
| `Space + ca` | Code actions (fix, refactor) |
| `Space + rn` | Rename symbol |
| `[d` / `]d` | Previous / Next error |

### Autocomplete (nvim-cmp)

| Key | Action |
|-----|--------|
| `Ctrl+Space` | Trigger completion manually |
| `Ctrl+J / K` | Navigate suggestions |
| `Enter` | Confirm suggestion |
| `Ctrl+E` | Dismiss popup |
| `:` then type | Filter commands (Tab / Shift+Tab, then Enter) |

### Copilot

| Key | Action |
|-----|--------|
| `Tab` | Accept full suggestion |
| `Ctrl+Right` | Accept next word only |
| `Ctrl+Down` | Accept next line only |
| `Alt+]` / `Alt+[` | Next / Previous suggestion |
| `Ctrl+]` | Dismiss suggestion |

### Git

| Key | Action |
|-----|--------|
| `]h` | Next git change |
| `[h` | Previous git change |

---

## Tips

- Press **`Space`** and wait 0.4s — a popup shows all available shortcuts (which-key)
- Type **`nvim .`** in your project folder to open the file tree automatically
- Type **`nvim filename.js`** to open a specific file directly
