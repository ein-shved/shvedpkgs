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
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end,
  },
  {
    "f-person/git-blame.nvim",
    lazy = false
  },
  {
    "Shatur/neovim-session-manager",
    lazy = false,
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
      vim.api.nvim_create_autocmd("VimLeavePre", {
        callback = function()
          if vim.bo.filetype ~= 'git'
              and not vim.bo.filetype ~= 'gitcommit'
              and not vim.bo.filetype ~= 'gitrebase'
          then
            session_manager.save_current_session()
          end
        end,
      })
    end,
  },
}

return plugins
