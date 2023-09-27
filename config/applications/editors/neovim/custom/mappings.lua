local M = {}

M.general = {
  n = {
    [";"] = { ":", "enter command mode", opts = { nowait = true } },
    ['<leader>dg'] = {
      function()
        if vim.diagnostic.is_disabled() then
          vim.diagnostic.enable()
        else
          vim.diagnostic.disable()
        end
      end,
      "Toggle diagnostic"
    }
  },
}

return M
