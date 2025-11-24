vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.wrap = false
vim.opt.linebreak = true
vim.opt.cursorline = true
vim.opt.showmatch = true
vim.opt.signcolumn = "yes"

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.clipboard = "unnamedplus"

vim.opt.mouse = "a"

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.opt.winborder = "rounded"

-- Allow gf to open non-existing files
vim.keymap.set("", "gf", ":edit <cfile><CR>", { noremap = false })

-- Reselect visual selection after indenting
vim.keymap.set("v", "<", "<gv", { noremap = true })
vim.keymap.set("v", ">", ">gv", { noremap = true })

-- Toggle off search highlight when ESC is pressed
vim.keymap.set("n", "<Esc>", ":noh<CR>", { noremap = true })

-- Go to tab by number
vim.keymap.set("n", "<leader>1", "1gt", { noremap = true })
vim.keymap.set("n", "<leader>2", "2gt", { noremap = true })
vim.keymap.set("n", "<leader>3", "3gt", { noremap = true })
vim.keymap.set("n", "<leader>4", "4gt", { noremap = true })
vim.keymap.set("n", "<leader>5", "5gt", { noremap = true })
vim.keymap.set("n", "<leader>6", "6gt", { noremap = true })
vim.keymap.set("n", "<leader>7", "7gt", { noremap = true })
vim.keymap.set("n", "<leader>8", "8gt", { noremap = true })
vim.keymap.set("n", "<leader>9", "9gt", { noremap = true })

-- Map <Esc> to exit terminal-mode
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { noremap = true })
-- Open terminal in a new tab in insert mode
vim.keymap.set("n", "<leader>t", ":tabnew | term<CR>i", { noremap = true, silent = true })

-- Explore
vim.g.netrw_liststyle = 3
vim.keymap.set("n", "<leader>e", ":Explore<CR>", { noremap = true })

vim.diagnostic.config({
  virtual_text = true,
})
--vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic Quickfix list" })

-- hightlight yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
  pattern = "*",
  desc = "highlight selection on yank",
  callback = function()
    vim.highlight.on_yank({
      timeout = 200,
      visual = true,
    })
  end,
})

-- restoure cursor to file position in previous editing session
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, "'")
    local line_count = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      vim.api.nvim_win_set_cursor(0, mark)
      -- defer centering slightly so it"s applied after render
      vim.schedule(function()
        vim.cmd("normal! zz")
      end)
    end
  end,
})

-- open help in vertical split
vim.api.nvim_create_autocmd("FileType", {
  pattern = "help",
  command = "wincmd L",
})

-- auto resize splits when the terminal"s window is resized
vim.api.nvim_create_autocmd("VimResized", {
  command = "wincmd =",
})

-- no auto continue comments on new line
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("no_auto_comment", {}),
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
})

-- show cursorline only in active window enable
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
  group = vim.api.nvim_create_augroup("active_cursorline", { clear = true }),
  callback = function()
    vim.opt_local.cursorline = true
  end,
})

-- show cursorline only in active window disable
vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
  group = "active_cursorline",
  callback = function()
    vim.opt_local.cursorline = false
  end,
})

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Autoformat buffer
--[[
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    vim.lsp.buf.format({
      timeout_ms = 200,
      async = false
    })
  end
})
]]
--

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    {
      "sainnhe/everforest",
      lazy = false,
      priority = 1000,
      config = function()
        -- Optionally configure and load the colorscheme
        -- directly inside the plugin declaration.
        vim.g.everforest_enable_italic = true
        vim.cmd.colorscheme("everforest")
      end,
    },
    {
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      dependencies = {
        "mason-org/mason-lspconfig.nvim",
        opts = {},
        dependencies = {
          {
            "mason-org/mason.nvim",
            opts = {
              ui = {
                icons = {
                  package_installed = "✓",
                  package_pending = "➜",
                  package_uninstalled = "✗",
                },
              },
            },
          },
          {
            "neovim/nvim-lspconfig",
            config = function()
              vim.lsp.config("lua_ls", {
                settings = {
                  Lua = {
                    workspace = {
                      library = {
                        vim.env.VIMRUNTIME,
                      },
                    },
                  },
                },
              })
            end,
          },
        },
      },
      config = function()
        require("mason-tool-installer").setup({
          ensure_installed = {
            "lua_ls",
            "ts_ls",
            "prettierd",
            "eslint",
            "htmlhint",
            "tailwindcss-language-server",
            "gopls"
          },
        })
      end,
    },
    {
      "nvim-treesitter/nvim-treesitter",
      branch = "master",
      lazy = false,
      build = ":TSUpdate",
      config = function()
        require("nvim-treesitter.configs").setup({
          ensure_installed = {
            "lua",
            "html",
            "tsx",
            "javascript",
            "typescript",
          },
          auto_install = true,
          hightlight = {
            enable = true,
            disable = function(_, buf)
              local max_filesize = 100 * 1024 -- 100 KB
              local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
              if ok and stats and stats.size > max_filesize then
                return true
              end
            end,
            additional_vim_regex_highlighting = false,
          },
        })
      end,
    },
    {
      "nvim-telescope/telescope.nvim",
      tag = "v0.1.9",
      dependencies = { "nvim-lua/plenary.nvim" },
      config = function()
        require("telescope").setup({
          defaults = {
            file_ignore_patterns = { "node_modules", ".git" },
            layout_strategy = "vertical",
            layout_config = {
              vertical = { width = 0.9, preview_height = 0.65 },
            },
          },
          pickers = {
            find_files = {
              hidden = true,
            },
          },
        })

        local builtin = require("telescope.builtin")
        vim.keymap.set("n", "<leader><leader>", builtin.find_files, { desc = "Telescope find files" })
        vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
        vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
        vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
        vim.keymap.set("n", "gd", builtin.lsp_definitions, { desc = "Goto definition" })
        vim.keymap.set("n", "gr", builtin.lsp_definitions, { desc = "Goto references" })
        vim.keymap.set("n", "gi", builtin.lsp_implementations, { desc = "Goto implementation" })
        vim.keymap.set("n", "gt", builtin.lsp_type_definitions, { desc = "Goto type definition" })
        vim.keymap.set("n", "gca", vim.lsp.buf.code_action, { desc = "Goto code actions" })
        vim.keymap.set("n", "rn", vim.lsp.buf.rename, { desc = "Rename" })
        vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "Search Diagnostics" })
        vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "Search current Word" })
        --[[
        vim.keymap.set("n", "<leader>fb", function()
          vim.lsp.buf.format({
            timeout_ms = 200
          })
        end, { desc = "Format buffer" })
        ]]
        --
      end,
    },
    {
      "hrsh7th/nvim-cmp",
      dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
      },
      config = function()
        local cmp = require("cmp")
        cmp.setup({
          --[[
					snippet = {
						expand = function(args)
							require("luasnip").lsp_expand(args.body)
						end,
					},
          ]]
          --
          auto_brackets = {},
          completion = { completeopt = "menu,menuone,noinsert" },
          mapping = cmp.mapping.preset.insert({
            -- Select the [n]ext/[p]revious item
            ["<C-n>"] = cmp.mapping.select_next_item(),
            ["<C-p>"] = cmp.mapping.select_prev_item(),

            -- Scroll the documentation window [b]ack/[f]orward
            ["<C-b>"] = cmp.mapping.scroll_docs(-4),
            ["<C-f>"] = cmp.mapping.scroll_docs(4),

            -- Accept ([y]es) or [e]xit the completion.
            --  This will auto-import if your LSP supports it.
            --  This will expand snippets if the LSP sent a snippet.
            ["<CR>"] = cmp.mapping.confirm({ select = true }),
            ["<C-e>"] = cmp.mapping.abort(),

            -- Manually trigger a completion from nvim-cmp.
            ["<C-Space>"] = cmp.mapping.complete({}),
          }),
          sources = {
            { name = "nvim_lsp" },
            { name = "path" },
            { name = "buffer",  option = { keyword_length = 3 } },
          },
        })
      end,
    },
    {
      "windwp/nvim-autopairs",
      event = "InsertEnter",
      config = true,
    },
    {
      "mfussenegger/nvim-lint",
      event = {
        "BufReadPre",
        "BufNewFile",
      },
      config = function()
        local lint = require("lint")
        lint.linters_by_ft = {
          lua = { "luacheck" },
          javascript = { "eslint" },
          typescript = { "eslint" },
          javascriptreact = { "eslint" },
          typescriptreact = { "eslint" },
          html = { "htmlhint" },
        }

        -- Run linting on specific events
        --vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
        --  callback = function()
        --    lint.try_lint()
        --  end,
        --})

        -- Keymap for manual linting
        --vim.keymap.set("n", "<leader>l", function()
        --  require("lint").try_lint()
        --end, { noremap = true, silent = true, desc = "Run linting" })
      end,
    },
    {
      "stevearc/conform.nvim",
      opts = {
        default_format_opts = {
          async = false,           -- not recommended to change
          quiet = false,           -- not recommended to change
          lsp_format = "fallback", -- not recommended to change
        },
        format_on_save = {
          timeout_ms = 1000,
        },
        formatters_by_ft = {
          -- Conform will run the first available formatter
          javascript = { "prettierd", "prettier", stop_after_first = true },
          typescript = { "prettierd", "prettier", stop_after_first = true },
          javascriptreact = { "prettierd", "prettier", stop_after_first = true },
          typescriptreact = { "prettierd", "prettier", stop_after_first = true },
          json = { "prettierd", "prettier", stop_after_first = true },
          css = { "prettierd", "prettier", stop_after_first = true },
          html = { "prettierd", "prettier", stop_after_first = true },
          markdown = { "prettierd", "prettier", stop_after_first = true },
        },
      },
    },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "everforest" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})
