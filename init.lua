-- ============================================================================
-- Bootstrap lazy.nvim (plugin manager)
-- ============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ============================================================================
-- Core Options
-- ============================================================================
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.expandtab = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.smartindent = true
opt.wrap = false
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.splitbelow = true
opt.splitright = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.undofile = true
opt.swapfile = false
opt.backup = false
opt.updatetime = 250
opt.timeoutlen = 300
opt.conceallevel = 0

-- ============================================================================
-- Plugins
-- ============================================================================
require("lazy").setup({

  -- ── Colorscheme ─────────────────────────────────────────────────────────
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = true,
        dim_inactive = { enabled = true, shade = "dark", percentage = 0.15 },
        integrations = {
          nvimtree = true,
          telescope = { enabled = true },
          treesitter = true,
          bufferline = true,
          noice = true,
          notify = true,
          gitsigns = true,
          which_key = true,
          indent_blankline = { enabled = true },
          mini = { enabled = true },
          dashboard = true,
        },
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- ── Syntax Highlighting ──────────────────────────────────────────────────
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup({
        ensure_installed = {
          "lua", "javascript", "typescript", "tsx", "python",
          "go", "rust", "html", "css", "json", "yaml", "markdown",
          "bash", "toml", "dockerfile",
        },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- ── File Tree ────────────────────────────────────────────────────────────
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = { width = 32, side = "left" },
        renderer = {
          group_empty = true,
          highlight_git = true,
          icons = {
            show = { file = true, folder = true, folder_arrow = true, git = true },
          },
        },
        filters = { dotfiles = false },
        git = { enable = true, ignore = false },
        actions = { open_file = { quit_on_open = false } },
        on_attach = function(bufnr)
          local api = require("nvim-tree.api")
          api.config.mappings.default_on_attach(bufnr)
          -- press Enter or l to open, h to collapse
          vim.keymap.set("n", "l", api.node.open.edit, { buffer = bufnr, silent = true })
          vim.keymap.set("n", "h", api.node.navigate.parent_close, { buffer = bufnr, silent = true })
        end,
      })
    end,
  },

  -- ── Fuzzy Finder ─────────────────────────────────────────────────────────
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      telescope.setup({
        defaults = {
          prompt_prefix = "  ",
          selection_caret = " ",
          path_display = { "smart" },
          file_ignore_patterns = { "node_modules", ".git/", "dist/", "build/" },
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<Esc>"] = actions.close,
            },
          },
        },
        pickers = {
          find_files = { hidden = true },
        },
      })
      telescope.load_extension("fzf")
    end,
  },

  -- ── Smooth Animations (cursor + scroll + window) ─────────────────────────
  {
    "echasnovski/mini.animate",
    version = "*",
    config = function()
      local animate = require("mini.animate")
      animate.setup({
        cursor = {
          enable = true,
          timing = animate.gen_timing.quadratic({ duration = 100, unit = "total" }),
        },
        scroll = {
          enable = true,
          timing = animate.gen_timing.quadratic({ duration = 200, unit = "total" }),
        },
        resize = { enable = true },
        open = { enable = true },
        close = { enable = true },
      })
    end,
  },

  -- ── Fancy UI / Command Line / Notifications ───────────────────────────────
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      {
        "rcarriga/nvim-notify",
        config = function()
          require("notify").setup({
            background_colour = "#1e1e2e",
            fps = 60,
            stages = "slide",
            timeout = 2500,
            render = "compact",
            top_down = true,
          })
          vim.notify = require("notify")
        end,
      },
    },
    config = function()
      require("noice").setup({
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
          },
        },
        presets = {
          bottom_search = true,
          command_palette = true,
          long_message_to_split = true,
          lsp_doc_border = true,
        },
      })
    end,
  },

  -- ── Statusline ───────────────────────────────────────────────────────────
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "catppuccin",
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          globalstatus = true,
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end,
  },

  -- ── Buffer Tabs (VSCode-like) ─────────────────────────────────────────────
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers",
          show_buffer_close_icons = true,
          show_close_icon = false,
          separator_style = "slant",
          diagnostics = false,
          offsets = {
            {
              filetype = "NvimTree",
              text = "  Explorer",
              highlight = "Directory",
              separator = true,
            },
          },
        },
      })
    end,
  },

  -- ── Which-key (popup shortcut guide) ─────────────────────────────────────
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").setup({
        preset = "modern",
        delay = 400,
      })
      require("which-key").add({
        { "<leader>e", desc = "Toggle file tree" },
        { "<leader>f", group = "Find/Search" },
        { "<leader>fg", desc = "Live grep (all files)" },
        { "<leader>/",  desc = "Search in buffer" },
        { "<leader>s",  group = "Split" },
        { "<leader>sv", desc = "Split vertical" },
        { "<leader>sh", desc = "Split horizontal" },
        { "<leader>t",  desc = "Open terminal" },
        { "<leader>d",  desc = "Duplicate line" },
      })
    end,
  },

  -- ── Indent Guides ────────────────────────────────────────────────────────
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      require("ibl").setup({
        indent = { char = "│", highlight = "IblIndent" },
        scope = { enabled = true, highlight = "IblScope" },
      })
    end,
  },

  -- ── Git Signs ────────────────────────────────────────────────────────────
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add          = { text = "▎" },
          change       = { text = "▎" },
          delete       = { text = "" },
          topdelete    = { text = "" },
          changedelete = { text = "▎" },
          untracked    = { text = "▎" },
        },
        current_line_blame = false,
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          vim.keymap.set("n", "]h", gs.next_hunk, { buffer = bufnr, desc = "Next hunk" })
          vim.keymap.set("n", "[h", gs.prev_hunk, { buffer = bufnr, desc = "Prev hunk" })
        end,
      })
    end,
  },

  -- ── Auto Pairs ───────────────────────────────────────────────────────────
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({})
    end,
  },

  -- ── Comments ─────────────────────────────────────────────────────────────
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },

  -- ── Rainbow Brackets ─────────────────────────────────────────────────────
  { "HiPhish/rainbow-delimiters.nvim" },

  -- ── Flash (quick jump anywhere on screen) ────────────────────────────────
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    config = function()
      require("flash").setup({})
    end,
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end,            desc = "Flash jump" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end,      desc = "Flash treesitter" },
    },
  },

  -- ── Dashboard (start screen) ──────────────────────────────────────────────
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("dashboard").setup({
        theme = "hyper",
        config = {
          week_header = { enable = true },
          shortcut = {
            { desc = "  Find File",    key = "f", action = "Telescope find_files" },
            { desc = "  Recent Files", key = "r", action = "Telescope oldfiles" },
            { desc = "  Grep",         key = "g", action = "Telescope live_grep" },
            { desc = "  Config",       key = "c", action = "e ~/.config/nvim/init.lua" },
            { desc = "  Quit",         key = "q", action = "qa" },
          },
          packages = { enable = true },
          project = { enable = true, limit = 8 },
          mru = { enable = true, limit = 10 },
          footer = {},
        },
      })
    end,
  },

  -- ── Scrollbar ────────────────────────────────────────────────────────────
  {
    "petertriho/nvim-scrollbar",
    config = function()
      require("scrollbar").setup({
        handle = { color = "#585b70" },
        marks = {
          Search = { color = "#f38ba8" },
          Cursor = { color = "#cba6f7" },
        },
      })
    end,
  },

  -- ── Mason (LSP installer UI) ──────────────────────────────────────────────
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup({ ui = { border = "rounded" } })
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls", "ts_ls", "pyright", "gopls",
          "rust_analyzer", "html", "cssls", "jsonls",
        },
        automatic_installation = true,
      })
    end,
  },

  -- ── LSP ───────────────────────────────────────────────────────────────────
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true })
      vim.api.nvim_create_autocmd("LspAttach", {
        group = group,
        callback = function(event)
          local bufnr = event.buf
          local opts = { buffer = bufnr, silent = true }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
          vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
        end,
      })

      local servers = {
        "lua_ls", "ts_ls", "pyright", "gopls",
        "rust_analyzer", "html", "cssls", "jsonls",
      }
      for _, server in ipairs(servers) do
        vim.lsp.config(server, { capabilities = capabilities })
        vim.lsp.enable(server)
      end

      vim.diagnostic.config({
        virtual_text  = true,
        signs         = true,
        underline     = true,
        update_in_insert = false,
        float         = { border = "rounded" },
      })
    end,
  },

  -- ── Autocomplete ──────────────────────────────────────────────────────────
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp     = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        window = {
          completion    = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-j>"]     = cmp.mapping.select_next_item(),
          ["<C-k>"]     = cmp.mapping.select_prev_item(),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"]      = cmp.mapping.confirm({ select = true }),
          ["<C-e>"]     = cmp.mapping.abort(),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },

  -- ── Auto-formatter (format on save) ──────────────────────────────────────
  {
    "stevearc/conform.nvim",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          javascript      = { "prettier" },
          typescript      = { "prettier" },
          javascriptreact = { "prettier" },
          typescriptreact = { "prettier" },
          html            = { "prettier" },
          css             = { "prettier" },
          json            = { "prettier" },
          yaml            = { "prettier" },
          markdown        = { "prettier" },
          python          = { "black" },
          go              = { "gofmt" },
          rust            = { "rustfmt" },
          lua             = { "stylua" },
        },
        format_on_save = {
          timeout_ms   = 500,
          lsp_fallback = true,
        },
      })
    end,
  },

  -- ── GitHub Copilot (Tab to accept inline suggestions) ────────────────────
  {
    "zbirenbaum/copilot.lua",
    cmd   = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = {
          enabled     = true,
          auto_trigger = true,
          keymap = {
            accept      = "<Tab>",
            accept_word = "<C-Right>",
            accept_line = "<C-Down>",
            next        = "<M-]>",
            prev        = "<M-[>",
            dismiss     = "<C-]>",
          },
        },
        panel = { enabled = false },
      })
    end,
  },

}, {
  ui = { border = "rounded" },
})

-- ============================================================================
-- Keymaps
-- ============================================================================
local map = vim.keymap.set
local o = { noremap = true, silent = true }

-- File Tree (Space+E; Cmd+B in Neovide). Ctrl+B is Herdr's prefix — do not bind it.
map("n", "<D-b>",    ":NvimTreeToggle<CR>", o)
map("n", "<leader>e",":NvimTreeToggle<CR>", o)

-- Fuzzy find files (Cmd+P / Ctrl+P)
map("n", "<D-p>", ":Telescope find_files<CR>", o)
map("n", "<C-p>", ":Telescope find_files<CR>", o)

-- Live grep all files (Cmd+Shift+F → use Space+fg in terminal)
map("n", "<D-F>",    ":Telescope live_grep<CR>", o)
map("n", "<leader>fg",":Telescope live_grep<CR>", o)

-- Search in current buffer (Cmd+F / Space+/)
map("n", "<D-f>",  ":Telescope current_buffer_fuzzy_find<CR>", o)
map("n", "<leader>/", ":Telescope current_buffer_fuzzy_find<CR>", o)

-- Save (Cmd+S / Ctrl+S)
map({ "n", "i", "v" }, "<D-s>", "<Esc>:w<CR>", o)
map("n", "<C-s>", ":w<CR>", o)

-- Close buffer (Cmd+W)
map("n", "<D-w>", ":bd<CR>", o)

-- Navigate buffers like VSCode tabs (Shift+H / Shift+L)
map("n", "<S-l>", ":bnext<CR>",     o)
map("n", "<S-h>", ":bprevious<CR>", o)

-- Move lines up/down (Alt+J / Alt+K, same as VSCode's Alt+Up/Down)
map("n", "<A-j>", ":m .+1<CR>==",        o)
map("n", "<A-k>", ":m .-2<CR>==",        o)
map("v", "<A-j>", ":m '>+1<CR>gv=gv",    o)
map("v", "<A-k>", ":m '<-2<CR>gv=gv",    o)

-- Window navigation (Ctrl+H/J/K/L)
map("n", "<C-h>", "<C-w>h", o)
map("n", "<C-j>", "<C-w>j", o)
map("n", "<C-k>", "<C-w>k", o)
map("n", "<C-l>", "<C-w>l", o)

-- Split windows
map("n", "<leader>sv", ":vsplit<CR>", o)
map("n", "<leader>sh", ":split<CR>",  o)

-- Clear search highlight with Escape
map("n", "<Esc>", ":noh<CR>", o)

-- Better indenting (stay in visual mode)
map("v", "<", "<gv", o)
map("v", ">", ">gv", o)

-- Select all (Cmd+A / Ctrl+A)
map("n", "<D-a>", "ggVG", o)
map("n", "<C-a>", "ggVG", o)

-- Duplicate line (Cmd+D / Space+D)
map("n", "<D-d>",    ":t.<CR>",    o)
map("n", "<leader>d",":t.<CR>",    o)

-- Comment line (gcc in normal, gc in visual — built into Comment.nvim)
-- Toggle comment with Ctrl+/ (remapped to gcc)
map("n", "<C-/>", "gcc", { remap = true, silent = true })
map("v", "<C-/>", "gc",  { remap = true, silent = true })

-- Terminal
map("n", "<leader>t", ":terminal<CR>", o)
map("t", "<Esc>",     "<C-\\><C-n>",   o)  -- Esc to exit terminal insert mode

-- Undo / Redo
map("n", "<D-z>",       "u",     o)
map("n", "<D-S-z>",     "<C-r>", o)

-- New line below/above without entering insert mode
map("n", "<leader>o", "o<Esc>", o)
map("n", "<leader>O", "O<Esc>", o)
