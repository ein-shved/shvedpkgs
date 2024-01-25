local null_ls = require "null-ls"

local formatting = null_ls.builtins.formatting
local lint = null_ls.builtins.diagnostics
local ca = null_ls.builtins.code_actions

local sources = {
  formatting.prettier,
  formatting.stylua,
  formatting.shfmt.with({
    extra_args = { "-i", "2" },
  }),

  lint.shellcheck,

  ca.statix,
  null_ls.builtins.diagnostics.pylint,
}

null_ls.setup {
  sources = sources,
}
