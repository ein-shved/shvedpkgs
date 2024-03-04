local M = {}

local function fontcfg(add)
  local m = string.gmatch(vim.o.guifont, '([^(:h)]+)')
  local font = m()
  local h = m()
  local nh = 8
  if not font then
    return
  end
  if h then
    nh = tonumber(h) + add
  end
  vim.o.guifont = font .. ":h" .. tostring(nh)
end

local function dap_mappings()
  local function dapm(cmd)
    return {
      function()
        require("dap")[cmd]()
      end,
      "Dap " .. cmd
    }
  end

  return {
    n = {
      ['<A-r>'] = dapm("continue"),
      ['<A-n>'] = dapm("step_over"),
      ['<A-i>'] = dapm("step_into"),
      ['<A-o>'] = dapm("step_out"),
      ['<A-b>'] = dapm("toggle_breakpoint"),
      ['<A-w>'] = {
        function()
          vim.ui.input({ prompt = "Condition:" },
            function(condition)
              require("dap").set_breakpoint(condition)
            end)
        end,
        "Dap conditional breakpoint"
      },
      ['<A-l>'] = {
        function()
          vim.ui.input({ prompt = "Logging:" },
            function(log)
              require("dap").set_breakpoint(nil, nil, log)
            end)
        end,
        "Dap logpoint"
      },
      ['<F5>'] = dapm("run_last"),
      ['<A-F5>'] = dapm("terminate"),
    }
  }
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
vim.keymap.set('!', '<S-Insert>', '<MiddleMouse>')

M.dap = dap_mappings()
return M
