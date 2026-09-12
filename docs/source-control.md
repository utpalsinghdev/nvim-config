# Source Control panel

VS Code–style git strip under the nvim-tree sidebar. Implemented in `lua/source_control.lua`, started from `init.lua` after lazy.nvim loads (`require("source_control").setup()`).

## Why it exists

The user already had Copilot **autocomplete** (`copilot.lua`) and wanted the other VS Code habit: see changed files, pick what to stage, generate a commit message from the diff, commit, and push — without leaving the sidebar.

nvim-tree cannot host a real collapsible section. Neogit/lazygit would work but would not sit under the tree. So this is a small companion UI, not a full git client.

## Why a float, not a split

The first version used `belowright split` on the tree window.

That failed as soon as a file opened: nvim-tree treats the extra split as a normal editor window, puts the file there, and the column collapses. Symptoms we actually saw:

- Source Control jumped to the **top** of the screen
- Statusline moved up
- File tree disappeared
- Clicking ✦ opened Copilot Chat as a vertical split and crushed the sidebar so names were unreadable
- Generate stayed on "Generating…" because the chat UI stole the session and the callback never completed cleanly

The panel is now an overlay (`relative = "win"`, `win` = the NvimTree window, `row` = bottom). The tree keeps its full window. Opening a file uses the real editor. Copilot Chat windows that still appear are closed.

## Layout and behavior

- **Collapsed:** one line, `▸ Source Control (N)`.
- **Expanded:** up to `floor(&lines * 0.4)` rows (minimum 6). More files → that window scrolls.
- **Files:** `git status --porcelain`. `○` unstaged, `●` staged. Click / `<CR>` / `<Space>` runs `git add` or `git restore --staged`.
- **Message:** shown in the panel. `i` opens `vim.ui.input`. Mouse clicks must **not** open that input (it was modal and blocked staging).
- **✦ / `g`:** generate. Uses `git diff --cached` if anything is staged, otherwise `git diff HEAD` plus untracked names. Sends that to `CopilotChat.ask(..., { headless = true })`. 25s timeout. Reply is stored in `state.message`.
- **Commit / `c`:** `git commit -F -` with that message. Refuses empty message or empty index.
- **Push / `p`:** `git push`, then `git push -u origin HEAD` if there is no upstream.

Clicks use `<LeftMouse>` + `getmousepos()` so the line is captured **as clicked**, not after a later redraw.

## Hookup

- nvim-tree events: `TreeOpen` → attach, `TreeClose` → close, `Resize` / `VimResized` → `nvim_win_set_config`, `TreeRendered` → reattach only if the float died.
- nvim-tree `window_picker` is **off** so open-file cannot target this UI.
- Filetype `SourceControl` is excluded from neominimap and `project_root()` buffer guessing.

## If you change it

Keep the float. Do not add a split "to make it feel more like a real window." If generate breaks, fix headless Copilot Chat or the timeout — do not `chat.open()`. If staging feels flaky, check click hit-testing (`state.hits`) before adding popups.
