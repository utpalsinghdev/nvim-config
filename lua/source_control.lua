-- Source Control overlay on the nvim-tree window. A float is used on purpose:
-- a real split gets stolen when a file opens and wrecks the sidebar.

local M = {}

local MAX_RATIO = 0.4
local ICON = "✦"
local FT = "SourceControl"

local state = {
  buf = nil,
  win = nil,
  expanded = false,
  message = "",
  generating = false,
  gen_token = 0,
  files = {},
  hits = {},
  syncing = false,
}

local function git_root()
  local git = vim.fn.finddir(".git", vim.fn.getcwd() .. ";")
  if git == "" then
    return nil
  end
  return vim.fn.fnamemodify(git, ":h")
end

local function git(args, stdin, cb)
  local root = git_root()
  if not root then
    cb({ code = 1, stdout = "", stderr = "Not a git repository." })
    return
  end
  local cmd = { "git", "-C", root }
  vim.list_extend(cmd, args)
  local opts = { text = true }
  if stdin then
    opts.stdin = stdin
  end
  vim.system(cmd, opts, function(obj)
    vim.schedule(function()
      cb(obj)
    end)
  end)
end

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO)
end

local function win_valid()
  return state.win and vim.api.nvim_win_is_valid(state.win)
end

local function buf_valid()
  return state.buf and vim.api.nvim_buf_is_valid(state.buf)
end

local function tree_win()
  local ok, api = pcall(require, "nvim-tree.api")
  if not ok or not api.tree.is_visible() then
    return nil
  end
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "NvimTree" then
      return win
    end
  end
  return nil
end

local function parse_status(stdout)
  local files = {}
  for line in vim.gsplit(stdout or "", "\n", { trimempty = true }) do
    if #line >= 3 then
      local xy = line:sub(1, 2)
      local rest = line:sub(4)
      local path = rest:match(" -> (.+)$") or rest
      path = path:gsub('^"', ""):gsub('"$', "")
      table.insert(files, {
        path = path,
        xy = xy,
        staged = xy:sub(1, 1) ~= " " and xy:sub(1, 1) ~= "?",
      })
    end
  end
  return files
end

local function truncate(text, width)
  if vim.fn.strdisplaywidth(text) <= width then
    return text
  end
  local short = vim.fn.pathshorten(text, 1)
  if vim.fn.strdisplaywidth(short) <= width then
    return short
  end
  return vim.fn.strcharpart(short, 0, math.max(1, width - 1)) .. "…"
end

local function panel_height()
  if not state.expanded then
    return 1
  end
  local wanted = math.max(7, #state.files + 5)
  local max_h = math.max(6, math.floor(vim.o.lines * MAX_RATIO))
  return math.max(1, math.min(wanted, max_h))
end

local function float_config(tw)
  local width = math.max(16, vim.api.nvim_win_get_width(tw))
  local theight = vim.api.nvim_win_get_height(tw)
  local h = math.min(panel_height(), theight)
  return {
    relative = "win",
    win = tw,
    width = width,
    height = h,
    row = math.max(0, theight - h),
    col = 0,
    style = "minimal",
    border = "none",
    focusable = true,
    zindex = 40,
  }
end

local function apply_win_opts(win)
  local wo = vim.wo[win]
  wo.number = false
  wo.relativenumber = false
  wo.signcolumn = "no"
  wo.foldcolumn = "0"
  wo.statuscolumn = ""
  wo.wrap = false
  wo.cursorline = true
  wo.list = false
  wo.spell = false
  wo.winhighlight = "Normal:NvimTreeNormal,EndOfBuffer:NvimTreeEndOfBuffer"
end

local function close_copilot_windows()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.bo[buf].filetype
    local name = vim.api.nvim_buf_get_name(buf)
    if ft:find("copilot%-chat", 1, false) or name:find("copilot%-chat", 1, false) then
      pcall(vim.api.nvim_win_close, win, true)
    end
  end
end

local function render()
  if not buf_valid() then
    return
  end

  local width = 32
  if win_valid() then
    width = vim.api.nvim_win_get_width(state.win)
  end

  local count = #state.files
  local left = (state.expanded and "▾" or "▸") .. " Source Control"
  if count > 0 then
    left = left .. " (" .. count .. ")"
  end
  local icon = state.generating and "…" or ICON
  local pad = width - vim.fn.strdisplaywidth(left) - vim.fn.strdisplaywidth(icon) - 1
  if pad < 1 then
    pad = 1
  end
  local header = left .. string.rep(" ", pad) .. icon

  local lines = { header }
  local hits = {
    header = 1,
    icon_col = width - 1,
    files = {},
  }

  if state.expanded then
    if count == 0 then
      table.insert(lines, "  No changes")
    else
      for i, file in ipairs(state.files) do
        local mark = file.staged and "●" or "○"
        local label = truncate(file.path, math.max(8, width - 4))
        table.insert(lines, "  " .. mark .. " " .. label)
        hits.files[#lines] = i
      end
    end
    table.insert(lines, string.rep("─", math.max(4, width)))
    local msg = state.message
    if msg == "" then
      msg = state.generating and "Generating…" or "Commit message  (press i to edit)"
    end
    table.insert(lines, "  " .. truncate(msg, math.max(8, width - 2)))
    hits.message = #lines
    table.insert(lines, "")
    local actions = "  Commit" .. string.rep(" ", math.max(2, width - 16)) .. "Push"
    table.insert(lines, actions)
    hits.actions = #lines
  end

  state.hits = hits
  local buf = state.buf
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].modified = false

  local ns = vim.api.nvim_create_namespace("source_control")
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  vim.api.nvim_buf_set_extmark(buf, ns, 0, 0, {
    end_row = 0,
    end_col = #lines[1],
    hl_group = "Directory",
  })
  if state.expanded then
    if hits.message then
      local hl = (state.message == "" and not state.generating) and "Comment" or "Normal"
      vim.api.nvim_buf_set_extmark(buf, ns, hits.message - 1, 0, {
        end_row = hits.message - 1,
        end_col = #lines[hits.message],
        hl_group = hl,
      })
    end
    if hits.actions then
      vim.api.nvim_buf_set_extmark(buf, ns, hits.actions - 1, 0, {
        end_row = hits.actions - 1,
        end_col = #lines[hits.actions],
        hl_group = "Identifier",
      })
    end
  end

  local tw = tree_win()
  if tw and win_valid() then
    pcall(vim.api.nvim_win_set_config, state.win, float_config(tw))
  end
end

local function refresh(cb)
  git({ "status", "--porcelain", "-u" }, nil, function(obj)
    if obj.code == 0 then
      state.files = parse_status(obj.stdout)
    else
      state.files = {}
    end
    render()
    if cb then
      cb()
    end
  end)
end

local function close()
  if win_valid() then
    pcall(vim.api.nvim_win_close, state.win, true)
  end
  state.win = nil
end

local function ensure_buf()
  if buf_valid() then
    return
  end
  local buf = vim.api.nvim_create_buf(false, true)
  state.buf = buf
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "hide"
  vim.bo[buf].swapfile = false
  vim.bo[buf].buflisted = false
  vim.bo[buf].modifiable = false
  vim.bo[buf].filetype = FT

  local opts = { buffer = buf, silent = true, nowait = true }
  vim.keymap.set("n", "<CR>", function()
    M.activate()
  end, opts)
  vim.keymap.set("n", "<Space>", function()
    M.activate()
  end, opts)
  vim.keymap.set("n", "<LeftMouse>", function()
    local pos = vim.fn.getmousepos()
    if pos.winid == state.win and pos.line > 0 then
      pcall(vim.api.nvim_win_set_cursor, state.win, { pos.line, 0 })
      M.activate(pos.line, pos.wincol)
    end
  end, opts)
  vim.keymap.set("n", "g", function()
    M.generate()
  end, opts)
  vim.keymap.set("n", "i", function()
    M.edit_message()
  end, opts)
  vim.keymap.set("n", "c", function()
    M.commit()
  end, opts)
  vim.keymap.set("n", "p", function()
    M.push()
  end, opts)
  vim.keymap.set("n", "r", function()
    refresh()
  end, opts)
end

local function open_overlay(tw)
  ensure_buf()
  local cfg = float_config(tw)
  if win_valid() then
    pcall(vim.api.nvim_win_set_config, state.win, cfg)
    if vim.api.nvim_win_get_buf(state.win) ~= state.buf then
      vim.api.nvim_win_set_buf(state.win, state.buf)
    end
  else
    state.win = vim.api.nvim_open_win(state.buf, false, cfg)
  end
  apply_win_opts(state.win)
end

function M.sync()
  if state.syncing then
    return
  end
  state.syncing = true
  local tw = tree_win()
  if not tw then
    close()
    state.syncing = false
    return
  end
  open_overlay(tw)
  refresh(function()
    state.syncing = false
  end)
end

function M.toggle()
  state.expanded = not state.expanded
  if state.expanded then
    refresh()
  else
    render()
  end
end

local function toggle_file(file)
  local args
  if file.staged then
    args = { "restore", "--staged", "--", file.path }
  else
    args = { "add", "--", file.path }
  end
  git(args, nil, function(obj)
    if obj.code ~= 0 then
      notify(vim.trim(obj.stderr ~= "" and obj.stderr or obj.stdout), vim.log.levels.ERROR)
      return
    end
    refresh()
  end)
end

function M.edit_message()
  vim.ui.input({ prompt = "Commit message: ", default = state.message }, function(value)
    if value == nil then
      return
    end
    state.message = vim.trim(value)
    render()
  end)
end

local function clean_message(text)
  text = vim.trim(text or "")
  text = text:gsub("^```%w*\n", ""):gsub("\n```$", "")
  text = text:gsub('^"', ""):gsub('"$', "")
  text = text:gsub("^'", ""):gsub("'$", "")
  return vim.trim(text)
end

function M.generate()
  if state.generating then
    return
  end
  if not git_root() then
    notify("Open a git repository to generate a commit message.", vim.log.levels.WARN)
    return
  end
  if not state.expanded then
    state.expanded = true
  end
  state.generating = true
  state.gen_token = state.gen_token + 1
  local token = state.gen_token
  render()

  vim.defer_fn(function()
    if state.generating and state.gen_token == token then
      state.generating = false
      render()
      close_copilot_windows()
      notify("Commit message timed out. Check that Copilot is signed in.", vim.log.levels.WARN)
    end
  end, 25000)

  local function finish_ok(text)
    if state.gen_token ~= token then
      return
    end
    state.message = clean_message(text)
    state.generating = false
    close_copilot_windows()
    render()
  end

  local function finish_err(msg)
    if state.gen_token ~= token then
      return
    end
    state.generating = false
    close_copilot_windows()
    render()
    notify(msg, vim.log.levels.ERROR)
  end

  local function with_diff(diff)
    if vim.trim(diff) == "" then
      finish_err("No changes to describe.")
      return
    end

    local ok, chat = pcall(require, "CopilotChat")
    if not ok then
      finish_err("CopilotChat is not installed. Run :Lazy sync.")
      return
    end

    local asked, err = pcall(function()
      chat.ask(
        "Write a concise git commit message for these changes. "
          .. "Use conventional commits (feat/fix/docs/chore/refactor). "
          .. "Reply with only the commit message, no quotes or explanation.\n\n"
          .. diff,
        {
          headless = true,
          callback = function(response)
            vim.schedule(function()
              local content = response
              if type(response) == "table" then
                content = response.content or response.message or ""
              end
              if clean_message(content) == "" then
                finish_err("Copilot returned an empty commit message.")
                return
              end
              finish_ok(content)
            end)
          end,
        }
      )
    end)
    vim.schedule(close_copilot_windows)
    if not asked then
      finish_err(tostring(err))
    end
  end

  git({ "diff", "--cached" }, nil, function(staged)
    if staged.code == 0 and vim.trim(staged.stdout) ~= "" then
      with_diff(staged.stdout)
      return
    end
    git({ "diff", "HEAD" }, nil, function(all)
      local diff = all.stdout or ""
      git({ "ls-files", "--others", "--exclude-standard" }, nil, function(untracked)
        local extra = vim.trim(untracked.stdout or "")
        if extra ~= "" then
          diff = diff .. "\n\nUntracked files:\n" .. extra
        end
        with_diff(diff)
      end)
    end)
  end)
end

function M.commit()
  local msg = vim.trim(state.message)
  if msg == "" then
    notify("Write or generate a commit message first.", vim.log.levels.WARN)
    return
  end
  git({ "diff", "--cached", "--name-only" }, nil, function(obj)
    if vim.trim(obj.stdout or "") == "" then
      notify("Stage at least one file before committing.", vim.log.levels.WARN)
      return
    end
    git({ "commit", "-F", "-" }, msg, function(result)
      if result.code ~= 0 then
        notify(vim.trim(result.stderr ~= "" and result.stderr or result.stdout), vim.log.levels.ERROR)
        return
      end
      state.message = ""
      notify(vim.trim(result.stdout):match("[^\n]+") or "Committed.")
      refresh()
    end)
  end)
end

function M.push()
  git({ "push" }, nil, function(obj)
    if obj.code == 0 then
      notify(vim.trim(obj.stderr ~= "" and obj.stderr or obj.stdout):match("[^\n]+") or "Pushed.")
      return
    end
    local err = obj.stderr or ""
    if err:find("no upstream", 1, true) or err:find("has no upstream branch", 1, true) then
      git({ "push", "-u", "origin", "HEAD" }, nil, function(retry)
        if retry.code ~= 0 then
          notify(vim.trim(retry.stderr ~= "" and retry.stderr or retry.stdout), vim.log.levels.ERROR)
          return
        end
        notify("Pushed and set upstream to origin.")
      end)
      return
    end
    notify(vim.trim(err ~= "" and err or obj.stdout), vim.log.levels.ERROR)
  end)
end

function M.activate(row, col)
  if not win_valid() then
    return
  end
  if not row then
    local cursor = vim.api.nvim_win_get_cursor(state.win)
    row = cursor[1]
    col = vim.fn.wincol()
  end
  local hits = state.hits
  local width = vim.api.nvim_win_get_width(state.win)
  if row == hits.header then
    if state.expanded and col >= width - 2 then
      M.generate()
    else
      M.toggle()
    end
    return
  end
  if not state.expanded then
    return
  end
  local file_i = hits.files[row]
  if file_i and state.files[file_i] then
    toggle_file(state.files[file_i])
    return
  end
  if row == hits.actions then
    if col < math.floor(width / 2) then
      M.commit()
    else
      M.push()
    end
  end
end

function M.setup()
  vim.api.nvim_create_autocmd({ "BufWritePost", "FocusGained" }, {
    group = vim.api.nvim_create_augroup("SourceControlRefresh", { clear = true }),
    callback = function()
      if win_valid() and state.expanded then
        refresh()
      end
    end,
  })
  vim.api.nvim_create_autocmd({ "VimResized", "WinResized" }, {
    group = vim.api.nvim_create_augroup("SourceControlResize", { clear = true }),
    callback = function()
      local tw = tree_win()
      if tw and win_valid() then
        pcall(vim.api.nvim_win_set_config, state.win, float_config(tw))
        render()
      end
    end,
  })

  local ok, api = pcall(require, "nvim-tree.api")
  if ok then
    api.events.subscribe(api.events.Event.TreeOpen, function()
      vim.schedule(M.sync)
    end)
    api.events.subscribe(api.events.Event.TreeClose, function()
      vim.schedule(close)
    end)
    api.events.subscribe(api.events.Event.Resize, function()
      vim.schedule(function()
        local tw = tree_win()
        if tw and win_valid() then
          pcall(vim.api.nvim_win_set_config, state.win, float_config(tw))
          render()
        end
      end)
    end)
    api.events.subscribe(api.events.Event.TreeRendered, function()
      vim.schedule(function()
        if tree_win() and not win_valid() then
          M.sync()
        end
      end)
    end)
  end

  vim.schedule(M.sync)
end

return M
