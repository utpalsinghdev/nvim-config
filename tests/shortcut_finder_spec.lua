local repo = vim.fn.getcwd()
package.path = repo .. "/lua/?.lua;" .. package.path
vim.g.mapleader = " "

local shortcut_finder = require("shortcut_finder")
local entries = shortcut_finder.entries()

local function has_entry(action_fragment, keys)
  for _, entry in ipairs(entries) do
    if entry.action:lower():find(action_fragment:lower(), 1, true) and entry.keys == keys then
      return true
    end
  end
  return false
end

assert(has_entry("copy", "y"), "the catalog must explain how to copy selected text")
assert(has_entry("paste", "p"), "the catalog must explain how to paste")
assert(has_entry("save", "Ctrl+s"), "the catalog must include configured editor shortcuts")

local copy_entry
for _, entry in ipairs(entries) do
  if entry.action == "Copy selected text" then
    copy_entry = entry
    break
  end
end
assert(copy_entry and copy_entry.details and copy_entry.details:find("Press v", 1, true), "copy help needs usage steps")
assert(shortcut_finder.match_score("paste", "Paste after the cursor p normal clipboard") >= 0, "paste must match paste help")
assert(
  shortcut_finder.match_score("paste", "Jump to the previous diagnostic normal keymap binding") < 0,
  "paste must filter unrelated shortcuts"
)
assert(shortcut_finder.match_score("cpy", "Copy selected text visual yank clipboard") >= 0, "small fuzzy queries should work")

local picker_options = shortcut_finder.picker_options()
assert(
  vim.fn.strdisplaywidth(picker_options.selection_caret) == vim.fn.strdisplaywidth(picker_options.entry_prefix),
  "selected and unselected rows must use equal-width prefixes"
)

shortcut_finder.setup({ key = "<leader>fk" })
assert(vim.api.nvim_get_commands({}).ShortcutFinder, ":ShortcutFinder command was not registered")

local shortcut_mapping
for _, mapping in ipairs(vim.api.nvim_get_keymap("n")) do
  if mapping.lhs == " fk" then
    shortcut_mapping = mapping
    break
  end
end
assert(shortcut_mapping, "Space+fk shortcut was not registered")
assert(shortcut_mapping.desc == "Search keyboard shortcuts", "shortcut mapping needs a searchable description")

vim.keymap.set("n", "<leader>?", "<cmd>Telescope buffers<CR>", { desc = "Existing fuzzy buffer search" })
shortcut_finder.setup({ key = "<leader>?" })
local existing_mapping = vim.fn.maparg(" ?", "n", false, true)
assert(existing_mapping.desc == "Existing fuzzy buffer search", "setup must not overwrite an existing keybinding")

print("shortcut-finder tests passed")
