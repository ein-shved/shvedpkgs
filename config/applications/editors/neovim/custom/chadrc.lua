local M = {}

local separator = "#808080"

M.plugins = "custom.plugins"

M.ui = {
  tabufline = {
    enabled = false,
  },
  hl_override = {
    WinSeparator = { bg = separator },
    Comment = { fg = "#909090" },
    Keyword = { fg = "#8080f0" },
  },
  hl_add = {
    GitBlame = { fg = "#404050", },
  },
  changed_themes = {
    chocolate = {
      base30 = {
        statusline_bg = separator,
      },
      base_16 = {
        base0E = "#8080f0",
      },
    },
  },
  theme = "chocolate",
}

return M
