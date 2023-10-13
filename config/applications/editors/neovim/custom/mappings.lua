local M = {}

local function fontcfg(add)
  local m = string.gmatch(vim.o.guifont, '([^(:h)]+)')
  local font = m()
  local h = m()
  if not font then
    return
  end
  if not h then
    h = 8
  else
    h = tonumber(h) + add
  end
  vim.o.guifont = font .. ":h" .. tostring(h)
end

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
    },
    ['<C-->'] = {
      function()
        fontcfg(-1)
      end,
      "Decrease font size"
    },
    ['<C-+>'] = {
      function()
        fontcfg(1)
      end,
      "Increase font size"
    },
  },
}

return M
