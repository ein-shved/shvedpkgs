local lspconfig = require "lspconfig"

-- if you just want default config for the servers then put them in a table
local servers = {
  "clangd",
  "lua_ls",
  "rnix",
  "rust_analyzer",
  "bashls",
  "cmake",
}

local on_attach = require("plugins.configs.lspconfig").on_attach

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = function(client, bufnr)
      -- Presave and restore formating capabilities of servers after NvChad
      -- changes them
      local formattingProvider =
          client.server_capabilities.documentFormattingProvider;
      local rangeFormattingProvider =
          client.server_capabilities.documentRangeFormattingProvider;

      on_attach(client, bufnr)

      client.server_capabilities.documentFormattingProvider = formattingProvider;
      client.server_capabilities.documentRangeFormattingProvider = rangeFormattingProvider;
    end,

    capabilities = require("plugins.configs.lspconfig").capabilities,
  }
end

-- Took from https://github.com/neovim/neovim/issues/21686
lspconfig.lua_ls.setup {
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using
        -- (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {
          'vim',
          'require'
        },
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },
}

lspconfig.clangd.setup {
  cmd = { 'clangd', '-j=8',
    '--query-driver=/home/shved/kl/**/*,/nix/store/**/*,*',
    '--header-insertion=never'
  },
}

lspconfig.rust_analyzer.setup {
  settings = {
    ['rust-analyzer'] = {
      diagnostics = {
        enable = true,
      }
    }
  }
}
