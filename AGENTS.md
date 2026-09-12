# AGENTS.md

This repo is a personal Neovim config (`~/.config/nvim`). It is meant to feel like VS Code: file tree on the left, buffer tabs, Copilot ghost text, and a Source Control strip under the tree.

Read this before changing UI, git, or the sidebar. Humans install from [README.md](./README.md). Shortcuts live in [NEOVIM_SETUP.md](./NEOVIM_SETUP.md). Source Control design is in [docs/source-control.md](./docs/source-control.md).

## Layout

| Path | Role |
|------|------|
| `init.lua` | Almost all plugins, options, and keymaps. Prefer small edits here. |
| `lua/source_control.lua` | Sidebar Source Control panel. Do not fold this back into `init.lua`. |
| `lazy-lock.json` | Pinned plugin commits. Update it when you add/change plugins (`:Lazy sync`). |
| `install.sh` / `update.sh` | Machine install and config self-update. |
| `docs/source-control.md` | Why Source Control is a float, click map, known failure modes. |

Plugins are **not** vendored. First `nvim` launch or `install.sh` clones them via lazy.nvim.

## Product intent

- **Leader is Space.** File tree is `<leader>e` (`:NvimTreeToggle`). Do not steal Ctrl+B (terminal multiplexer prefix).
- Sidebar title is the **cwd folder name**, not the word "Explorer" (`bufferline` offset + `nvim-tree` `root_folder_label = false`).
- Source Control is a **collapsible strip at the bottom of the file tree**. Expanded height is **capped at 40% of `&lines`**; the file list scrolls after that.
- Copilot (`zbirenbaum/copilot.lua`) is Tab-to-accept ghost text. **Commit messages** use Copilot Chat (`CopilotC-Nvim/CopilotChat.nvim`) from the ✦ icon, headless. Do not open the chat sidebar for that.

## Source Control — do not regress

A real `split` under nvim-tree **will break**. nvim-tree (or Copilot Chat) steals that window when you open a file or generate a message: tree vanishes, statusline jumps, panel ends up at the top.

The panel **must** stay a `nvim_open_win` float (`relative = "win"`, anchored to the NvimTree window). See `lua/source_control.lua`.

Also:

- nvim-tree `actions.open_file.window_picker.enable = false` so a file does not land in a picker/other sidebar window.
- Filetype is `SourceControl`. Keep it out of minimap, `project_root()`, and any window picker exclude lists.
- Clicks: header toggles; far-right ✦ generates; file lines stage/unstage; Commit/Push on the actions row. **Do not** open `vim.ui.input` on mouse click (it blocked staging). Edit message with `i` only.
- Generate must stay `headless = true`. Close leftover `copilot-chat` windows. Time out instead of leaving "Generating…".

## Conventions

- Neovim **0.10+**. Use `vim.system`, not deprecated `jobstart` wrappers, unless you are matching existing code.
- Match the style in `init.lua`: two-space indent, short comments, no extra abstractions.
- Do not add Co-authored-by / agent attribution on commits.
- Do not rewrite README install tables unless the user asks.
- After plugin spec changes, leave `lazy-lock.json` updated.

## How to verify

1. Restart Neovim (or `:qa` and reopen). `:Lazy sync` if Copilot Chat is missing.
2. In a git repo, `<leader>e`. Collapsed bar should sit on the **bottom** of the tree.
3. Open several files from the tree. Tree and Source Control must stay put.
4. Expand the bar, click files to stage/unstage **without** a commit-message popup.
5. Press `i` to edit the message; ✦ to generate. Layout must not shift left.
6. Commit and Push from the panel.

`:Copilot auth` is required once per machine for both ghost text and generate.
