local lspconfig = require("lspconfig")

-- if you just want default config for the servers then put them in a table
local servers = {
  "rnix",
  "bashls",
  "cmake",
  lua_ls = {
    settings = {
-- Took from https://github.com/neovim/neovim/issues/21686
      Lua = {
        runtime = {
          -- Tell the language server which version of Lua you're using
          -- (most likely LuaJIT in the case of Neovim)
          version = "LuaJIT",
        },
        diagnostics = {
          -- Get the language server to recognize the `vim` global
          globals = {
            "vim",
            "require",
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
  },
  clangd = {
    cmd = {
      "clangd",
      "-j=8",
      "--query-driver=/home/shved/kl/**/*,/nix/store/**/*,*",
      "--header-insertion=never",
    },
  },
  rust_analyzer = {
    settings = {
      ["rust-analyzer"] = {
        diagnostics = {
          enable = true,
        },
      },
    },
  },
}

local on_attach_orig = require("plugins.configs.lspconfig").on_attach
local function on_attach(client, bufnr)
  -- Presave and restore formating capabilities of servers after NvChad
  -- changes them
  local formattingProvider = client.server_capabilities.documentFormattingProvider
  local rangeFormattingProvider = client.server_capabilities.documentRangeFormattingProvider

  on_attach_orig(client, bufnr)

  client.server_capabilities.documentFormattingProvider = formattingProvider
  client.server_capabilities.documentRangeFormattingProvider = rangeFormattingProvider
end

for lsp, val in pairs(servers) do
  local setup = {
    on_attach = on_attach,
    capabilities = require("plugins.configs.lspconfig").capabilities,
  }
  if type(lsp) == "number" and type(val) == "string" then
    lsp = val
    val = nil
  end
  if val ~= nil then
    setup = vim.tbl_deep_extend("force", setup, val)
  end
  lspconfig[lsp].setup(setup)
end
