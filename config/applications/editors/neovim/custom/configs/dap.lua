local dap, dapui = require("dap"), require("dapui")

dapui.setup()

dap.listeners.before.attach.dapui_config = function()
  dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
  dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
  dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
  dapui.close()
end

local function set_dap_sign(sign, text, class)
  vim.fn.sign_define(sign, { text=text, texthl=class, linehl = '', numhl = '' })
end

local function set_dap_highlight(class, fg)
  vim.cmd.highlight({args = { class, 'guifg=' .. fg }})
end

set_dap_highlight('DapBreakpoint', '#993939')
set_dap_highlight('DapLogPoint', '#61afef')
set_dap_highlight('DapStopped', '#98c379')

set_dap_sign('DapBreakpoint', '', 'DapBreakpoint')
set_dap_sign('DapBreakpointCondition', '', 'DapBreakpoint')
set_dap_sign('DapBreakpointRejected', '', 'DapBreakpoint')
set_dap_sign('DapLogPoint', '', 'DapLogPoint')
set_dap_sign('DapStopped', '', 'DapStopped')
