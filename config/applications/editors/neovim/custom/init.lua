local opts = {
  number = false,
  wrap = false,

  guifont = "JetBrainsMono Nerd Font:h8",

  ruler = true,
  laststatus = 2,

  list = true,
  listchars = 'tab:→\\ ,nbsp:␣,trail:•,precedes:«,extends:»',

  tw = 80,
  colorcolumn = "81",
  backspace = "indent,eol,start",
  expandtab = true,
  autoindent = true,
  smartindent = true,
  tabstop = 4,
  shiftwidth = 4,

  formatoptions = "croql",

  hidden = false,
}

for n, v in pairs(opts) do
  vim.opt[n] = v
end

local autocmd = vim.api.nvim_create_autocmd

autocmd("BufWritePre", {
  pattern = '*',
  command = ':%s/\\s\\+$//e',
})

autocmd("FileType", {
  pattern = { "xml", "nix", "lua" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
  end,
})

autocmd("CursorHold", {
  callback = function()
    vim.diagnostic.config({ virtual_text = false, })
    if not vim.diagnostic.is_disabled() then
      vim.diagnostic.open_float({
        focusable = false,
      })
    end
  end,
})
