local plugins = {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        -- defaults
        "vim",
        "lua",
        "bash",

        "json",
        "yaml",

        "c",
        "cpp",
        "python",
        "nix",
        "rust",

        "cmake",
        "make",

        "comment",
      },
    },
  },
  {
    "nvim-tree/nvim-tree.lua",
    enabled = false,
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = { "Neotree" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    lazy = false,
    opts = function()
      return require("custom.configs.neo-tree")
    end,
    config = function(_, opts)
      require("neo-tree").setup(opts)
      vim.api.nvim_create_user_command("Ex", function()
        vim.cmd("Neotree reveal")
      end, {})
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("plugins.configs.lspconfig")
      require("custom.configs.lspconfig")
    end,
  },
  {
    "f-person/git-blame.nvim",
    lazy = false,
    dependencies = {
      "NvChad/base46",
    },
    config = function()
      vim.g.gitblame_highlight_group = "GitBlame"
    end,
  },
  {
    "Shatur/neovim-session-manager",
    lazy = false,
    enabled = vim.g.neovide and true or false,
    opts = function()
      local config = require("session_manager.config")
      return {
        autoload_mode = config.AutoloadMode.CurrentDir,
        autosave_last_session = true,
      }
    end,
    config = function(_, opts)
      local session_manager = require("session_manager")
      session_manager.setup(opts)
      vim.api.nvim_create_autocmd("BufWritePost", {
        callback = function()
          if
              vim.bo.filetype ~= "git"
              and not vim.bo.filetype ~= "gitcommit"
              and not vim.bo.filetype ~= "gitrebase"
          then
            session_manager.save_current_session()
          end
        end,
      })
    end,
  },
  {
    "figsoda/nix-develop.nvim",
    cmd = { "NixDevelop", "NixShell", "RiffShell" },
  },
  {
    "neovim/nvim-lspconfig",

    dependencies = {
      "jose-elias-alvarez/null-ls.nvim",
      config = function()
        require("custom.configs.null-ls")
      end,
    },

    config = function()
      require("plugins.configs.lspconfig")
      require("custom.configs.lspconfig")
    end,
  },
  {
    "uga-rosa/utf8.nvim",
  },
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "NvChad/base46",
    },
    config = function()
      require("custom.configs.dap")
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
    },
  },
  {
    'mrcjkb/rustaceanvim',
    dependencies = {
      "mfussenegger/nvim-dap",
    },
    version = '^3',
    ft = { 'rust' },
  },
  {
    "L3MON4D3/LuaSnip",
    opts = { history = true,},
    config = function(_, opts)
      require("luasnip").config.set_config(opts)

      -- lua format
      require("luasnip.loaders.from_lua").load()
      require("luasnip.loaders.from_lua").lazy_load { paths = vim.g.lua_snippets_path or "" }

      vim.api.nvim_create_autocmd("InsertLeave", {
        callback = function()
          if
              require("luasnip").session.current_nodes[vim.api.nvim_get_current_buf()]
              and not require("luasnip").session.jump_active
          then
            require("luasnip").unlink_current()
          end
        end,
      })
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    opts = function()
      local opts = require "plugins.configs.cmp"
      opts.completion.autocomplete = false
      vim.keymap.set('i', '<C-n>', function() require('cmp').complete() end, {})
    end,
  },
  {
    "windwp/nvim-autopairs",
    enabled = false,
  },
  {
    "rafamadriz/friendly-snippets",
    enabled = false,
  },
}

return plugins
