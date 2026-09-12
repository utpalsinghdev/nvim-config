local M = {}

local essentials = {
  {
    mode = "Visual",
    keys = "y",
    action = "Copy selected text",
    keywords = "copy yank clipboard",
    details = "Press v in Normal mode, select text with the movement keys, then press y. The selection is copied to the system clipboard.",
  },
  {
    mode = "Normal",
    keys = "y{motion}",
    action = "Copy text covered by a motion",
    keywords = "copy yank clipboard",
    details = "Press y followed by a movement. For example, yw copies to the end of the word and y$ copies to the end of the line.",
  },
  {
    mode = "Normal",
    keys = "yy",
    action = "Copy the current line",
    keywords = "copy yank line clipboard",
    details = "Press Esc to enter Normal mode, then press y twice. The complete current line is copied.",
  },
  {
    mode = "Normal",
    keys = "p",
    action = "Paste after the cursor",
    keywords = "paste clipboard",
    details = "Press Esc to enter Normal mode, then press p. Copied text is inserted after the cursor or below the current line.",
  },
  {
    mode = "Normal",
    keys = "P",
    action = "Paste before the cursor",
    keywords = "paste clipboard",
    details = "Press Esc to enter Normal mode, then press Shift+p. Copied text is inserted before the cursor or above the current line.",
  },
  { mode = "Normal", keys = "u", action = "Undo the last change", keywords = "undo history" },
  { mode = "Normal", keys = "Ctrl+r", action = "Redo the last undone change", keywords = "redo undo history" },
  { mode = "Normal", keys = "dd", action = "Delete the current line", keywords = "delete cut line" },
  { mode = "Normal", keys = "x", action = "Delete the character under the cursor", keywords = "delete character" },
  { mode = "Normal", keys = "ciw", action = "Replace the word under the cursor", keywords = "change edit word" },
  { mode = "Normal", keys = "/", action = "Search inside the current file", keywords = "find text buffer" },
  { mode = "Normal", keys = "n", action = "Jump to the next search result", keywords = "search next" },
  { mode = "Normal", keys = "N", action = "Jump to the previous search result", keywords = "search previous" },
  { mode = "Normal", keys = "gg", action = "Jump to the start of the file", keywords = "go top first line" },
  { mode = "Normal", keys = "G", action = "Jump to the end of the file", keywords = "go bottom last line" },
  { mode = "Normal", keys = "Ctrl+s", action = "Save the current file", keywords = "write file" },
  { mode = "Normal", keys = "Ctrl+w", action = "Close the current buffer", keywords = "close tab buffer" },
  { mode = "Normal", keys = "Ctrl+p", action = "Find a file in the project", keywords = "files fuzzy search" },
  { mode = "Normal", keys = "Ctrl+Shift+f", action = "Search text across the project", keywords = "grep find project" },
  { mode = "Normal", keys = "Ctrl+f", action = "Fuzzy-search inside the current file", keywords = "find buffer" },
  { mode = "Normal", keys = "Space+e", action = "Toggle the file explorer", keywords = "tree sidebar files" },
  { mode = "Normal", keys = "Shift+l", action = "Open the next buffer tab", keywords = "tab buffer next" },
  { mode = "Normal", keys = "Shift+h", action = "Open the previous buffer tab", keywords = "tab buffer previous" },
  { mode = "Normal", keys = "Alt+j", action = "Move the current line down", keywords = "reorder line" },
  { mode = "Normal", keys = "Alt+k", action = "Move the current line up", keywords = "reorder line" },
  { mode = "Normal", keys = "Ctrl+h/j/k/l", action = "Move between editor windows", keywords = "navigate pane split" },
  { mode = "Normal", keys = "Space+sv", action = "Split the editor vertically", keywords = "window pane" },
  { mode = "Normal", keys = "Space+sh", action = "Split the editor horizontally", keywords = "window pane" },
  { mode = "Normal", keys = "Ctrl+a", action = "Select the entire file", keywords = "select all" },
  { mode = "Normal", keys = "Space+d", action = "Duplicate the current line", keywords = "copy duplicate line" },
  { mode = "Normal", keys = "Ctrl+/", action = "Toggle a line comment", keywords = "comment code" },
  { mode = "Visual", keys = "Ctrl+/", action = "Toggle comments for the selection", keywords = "comment code" },
  { mode = "Normal", keys = "Space+t", action = "Open a terminal", keywords = "shell console" },
  { mode = "Terminal", keys = "Esc", action = "Leave terminal input mode", keywords = "normal exit terminal" },
  { mode = "Normal", keys = "gd", action = "Go to the symbol definition", keywords = "lsp code definition" },
  { mode = "Normal", keys = "gr", action = "Find references to the symbol", keywords = "lsp code usages" },
  { mode = "Normal", keys = "K", action = "Show documentation for the symbol", keywords = "lsp hover docs" },
  { mode = "Normal", keys = "Space+ca", action = "Show available code actions", keywords = "lsp quick fix" },
  { mode = "Normal", keys = "Space+rn", action = "Rename the current symbol", keywords = "lsp refactor" },
  { mode = "Normal", keys = "Space+fk", action = "Search keyboard shortcuts", keywords = "help keymap bindings" },
}

local mode_names = {
  n = "Normal",
  i = "Insert",
  x = "Visual",
  v = "Visual",
  c = "Command",
  t = "Terminal",
}

local function pretty_keys(lhs)
  local keys = lhs
  if keys:sub(1, 1) == " " then
    keys = "Space+" .. keys:sub(2)
  end
  keys = keys:gsub("<leader>", "Space+")
  keys = keys:gsub("<C%-([^>]+)>", "Ctrl+%1")
  keys = keys:gsub("<S%-([^>]+)>", "Shift+%1")
  keys = keys:gsub("<A%-([^>]+)>", "Alt+%1")
  keys = keys:gsub("<M%-([^>]+)>", "Alt+%1")
  keys = keys:gsub("<CR>", "Enter")
  keys = keys:gsub("<Esc>", "Esc")
  keys = keys:gsub("<Tab>", "Tab")
  keys = keys:gsub("<Space>", "Space")
  return keys
end

local function add_registered(entries, seen, maps, mode)
  for _, keymap in ipairs(maps) do
    if keymap.lhs ~= "" and not keymap.lhs:find("<Plug>", 1, true) then
      local keys = pretty_keys(keymap.lhs)
      local name = mode_names[mode] or mode
      local id = name .. "\0" .. keys
      if not seen[id] then
        local action = keymap.desc
        if not action or action == "" then
          action = keymap.rhs ~= "" and keymap.rhs or "Lua keybinding"
        end
        entries[#entries + 1] = {
          mode = name,
          keys = keys,
          action = action,
          keywords = (keymap.rhs or "") .. " keymap binding",
        }
        seen[id] = true
      end
    end
  end
end

local function fuzzy_word_score(token, word)
  local next_index = 1
  local score = 0
  for character in token:gmatch(".") do
    local found = word:find(character, next_index, true)
    if not found then
      return nil
    end
    score = score + found - next_index
    next_index = found + 1
  end
  return score
end

function M.match_score(prompt, text)
  prompt = vim.trim(prompt:lower())
  text = text:lower()
  if prompt == "" then
    return 0
  end

  local total = 0
  for token in prompt:gmatch("%S+") do
    local exact = text:find(token, 1, true)
    if exact then
      total = total + exact - 1
    else
      local best
      for word in text:gmatch("[%w_+/-]+") do
        local score = fuzzy_word_score(token, word)
        if score ~= nil and (best == nil or score < best) then
          best = score
        end
      end
      if best == nil then
        return -1
      end
      total = total + 100 + best
    end
  end
  return total
end

function M.picker_options()
  return {
    layout_strategy = "horizontal",
    layout_config = {
      width = 0.88,
      height = 0.72,
      preview_width = 0.42,
      prompt_position = "top",
    },
    sorting_strategy = "ascending",
    selection_caret = "> ",
    entry_prefix = "  ",
  }
end

function M.entries()
  local entries = vim.deepcopy(essentials)
  local seen = {}
  for _, entry in ipairs(entries) do
    seen[entry.mode .. "\0" .. entry.keys] = true
  end

  for _, mode in ipairs({ "n", "i", "x", "c", "t" }) do
    add_registered(entries, seen, vim.api.nvim_get_keymap(mode), mode)
    add_registered(entries, seen, vim.api.nvim_buf_get_keymap(0, mode), mode)
  end

  table.sort(entries, function(left, right)
    if left.action == right.action then
      return left.keys < right.keys
    end
    return left.action < right.action
  end)
  return entries
end

function M.open()
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local previewers = require("telescope.previewers")
  local sorters = require("telescope.sorters")
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local opts = M.picker_options()

  pickers.new(opts, {
    prompt_title = "Search shortcuts by action",
    results_title = "Shortcuts",
    finder = finders.new_table({
      results = M.entries(),
      entry_maker = function(entry)
        return {
          value = entry,
          display = string.format("%-38s  %-9s  %s", entry.action, entry.mode, entry.keys),
          ordinal = table.concat({ entry.action, entry.keys, entry.mode, entry.keywords or "" }, " "),
        }
      end,
    }),
    sorter = sorters.Sorter:new({
      discard = true,
      scoring_function = function(_, prompt, line)
        return M.match_score(prompt, line)
      end,
    }),
    previewer = previewers.new_buffer_previewer({
      title = "How to use",
      define_preview = function(self, entry)
        local shortcut = entry.value
        local details = shortcut.details
          or string.format("Press %s while you are in %s mode.", shortcut.keys, shortcut.mode)
        local lines = {
          shortcut.action,
          "",
          "Shortcut: " .. shortcut.keys,
          "Mode: " .. shortcut.mode,
          "",
          "How to use:",
        }
        vim.list_extend(lines, vim.split(details, "\n", { plain = true }))
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
        vim.bo[self.state.bufnr].filetype = "markdown"
      end,
    }),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local selected = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if selected then
          vim.schedule(function()
            vim.notify(string.format("%s: %s (%s mode)", selected.value.action, selected.value.keys, selected.value.mode))
          end)
        end
      end)
      return true
    end,
  }):find()
end

function M.setup(opts)
  opts = opts or {}
  local key = opts.key or "<leader>fk"
  vim.api.nvim_create_user_command("ShortcutFinder", M.open, {
    desc = "Search keyboard shortcuts",
    force = true,
  })
  if vim.fn.maparg(key, "n") ~= "" then
    return
  end
  vim.keymap.set("n", key, M.open, {
    desc = "Search keyboard shortcuts",
    silent = true,
  })
end

return M
