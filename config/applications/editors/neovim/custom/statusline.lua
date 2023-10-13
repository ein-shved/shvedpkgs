local fn = vim.fn

local sep_l = ""
local sep_r = " "
local function calc_visible_len(s)
  local utf8 = require("utf8")
  local nonvis = 0
  local spos, epos = string.find(s, "%%#[^%^#]*#")
  while spos do
    nonvis = nonvis + epos - spos + 1
    spos, epos = string.find(s, "%%#[^%^#]*#", epos + 1)
  end
  return (utf8.len(s) or 0) - nonvis
end

local function stbufnr()
  return fn.winbufnr(vim.g.statusline_winid)
end

local function is_activewin()
  return vim.api.nvim_get_current_win() == vim.g.statusline_winid
end

local function override_mode(orig)
  return orig
end

local function splitpath(inputstr)
  local t = {}
  for str in string.gmatch(inputstr, "([^/]+)") do
    table.insert(t, str)
  end
  return t
end

local function override_fileInfo(orig, space)
  local icon = " 󰈚 "
  local filename = fn.expand("#" .. stbufnr())
  local utf8 = require("utf8")

  if filename == "" then
    filename = "Empty"
  end

  if filename ~= "Empty " then
    local devicons_present, devicons = pcall(require, "nvim-web-devicons")
    filename = fn.fnamemodify(filename, ":p:~:.")
    local fnlen = utf8.len(filename)
    local splited = splitpath(filename)
    local shorted = false

    while fnlen + 5 > space and #splited > 1 do
      local section = table.remove(splited, 1)
      fnlen = fnlen - utf8.len(section) - 1
      if not shorted then
        fnlen = fnlen + 3 -- leading ../
      end
      shorted = true
    end

    if shorted then
      filename = "../" .. table.concat(splited, "/")
    end

    if devicons_present then
      local ft_icon = devicons.get_icon(filename)
      icon = (ft_icon ~= nil and " " .. ft_icon) or ""
    end

    filename = " " .. filename .. " "
  end

  return "%#St_file_info#" .. icon .. filename .. "%#St_file_sep#" .. sep_r
end

local function override_git(orig)
  return orig
end

local function override_lsp_progress(orig)
  return orig
end

local function override_lsp_diag(orig)
  return orig
end
local function override_lsp_status(orig)
  return orig
end
local function override_cwd(orig)
  if not is_activewin() then
    return ""
  end
  return orig
end
local function override_pos(orig)
  local left_sep = "%#St_pos_sep#" .. sep_l .. "%#St_pos_icon#" .. " "

  local current_line = fn.line(".", vim.g.statusline_winid)
  local total_line = fn.line("$", vim.g.statusline_winid)
  local text = ""
  if not vim.wo[vim.g.statusline_winid].number then
    text = tostring(current_line)
  else
    text = math.modf((current_line / total_line) * 100) .. tostring("%%")
    text = string.format("%4s", text)
  end

  text = (current_line == 1 and "Top") or text
  text = (current_line == total_line and "Bot") or text

  return left_sep .. "%#St_pos_text#" .. " " .. text .. " "
end

local function override(modules)
  local mode = modules[1]
  local fileInfo = modules[2]
  local git = modules[3]

  local lsp_progress = modules[5]

  local lsp_diag = modules[7]
  local lsp_status = modules[8]
  local cwd = modules[9]
  local pos = modules[10]

  local left = vim.api.nvim_win_get_width(vim.g.statusline_winid)

  local function do_override(module, overloader, never_supress)
    if left > 0 or never_supress then
      module = overloader(module, left) or ""
      left = left - calc_visible_len(module)
      if left < 0 and not never_supress then
        module = ""
      end
    else
      module = ""
    end
    return module
  end
  -- Overriding modules in order of importance. So when the space in statusline
  -- will gone - the less important modules will be suppressed

  mode = do_override(mode, override_mode, true) -- never suppress mode
  pos = do_override(pos, override_pos)

  fileInfo = do_override(fileInfo, override_fileInfo)
  lsp_diag = do_override(lsp_diag, override_lsp_diag)

  -- TODO move cwd to global scope
  cwd = do_override(cwd, override_cwd)
  git = do_override(git, override_git)

  lsp_status = do_override(lsp_status, override_lsp_status)
  lsp_progress = do_override(lsp_progress, override_lsp_progress)

  modules[1] = mode
  modules[2] = fileInfo
  modules[3] = git

  modules[5] = lsp_progress

  modules[7] = lsp_diag
  modules[8] = lsp_status
  modules[9] = cwd
  modules[10] = pos
end

local M = {}

M.theme = "default"
M.overriden_modules = override

return M
