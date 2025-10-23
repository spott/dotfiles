-- ================= helpers =================
local uv = vim.uv or vim.loop

local function project_root()
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
    local root = client.config and client.config.root_dir
    if root and root ~= '' then return root end
  end
  local ok, toplevel = pcall(function()
    local dir = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':h')
    return vim.fn.systemlist('git -C ' .. vim.fn.shellescape(dir) .. ' rev-parse --show-toplevel')[1]
  end)
  if ok and toplevel and toplevel ~= '' then return toplevel end
  return uv.cwd()
end

local function top_dir_plus_file()
  local full = vim.api.nvim_buf_get_name(0)
  if full == '' then return '[No Name]' end
  local root = project_root()
  local rel
  if root and full:sub(1, #root) == root then
    rel = full:sub(#root + 2)
  else
    rel = vim.fn.fnamemodify(full, ':t')
  end
  local parts = {}
  for seg in rel:gmatch('[^/]+') do parts[#parts+1] = seg end
  if #parts >= 2 then return parts[1] .. '/' .. parts[#parts] end
  return parts[#parts]
end

local function tiny_mode(m)
  m = (m or ''):upper()
  local map = {
    NORMAL='N', INSERT='I', VISUAL='V', ['V-LINE']='V', ['V-BLOCK']='V',
    SELECT='S', ['S-LINE']='S', ['S-BLOCK']='S',
    REPLACE='R', ['V-REPLACE']='R',
    COMMAND='C', EX='X', MORE='M', CONFIRM='?', SHELL='!', TERM='T'
  }
  return map[m] or (m:sub(1,1) ~= '' and m:sub(1,1) or '?')
end

local function not_utf8()
  local enc = (vim.bo.fenc ~= '' and vim.bo.fenc) or vim.o.enc
  return (enc or ''):lower() ~= 'utf-8'
end

local function winwide(min)
  return function() return vim.fn.winwidth(0) >= (min or 80) end
end

-- separators: arrows when wide, none when tight
local section_seps = (vim.o.columns >= 100) and { left = '', right = '' } or { left = '', right = '' }
local comp_seps    = (vim.o.columns >= 100) and { left = '', right = '' } or { left = '', right = '' }

-- devicons (optional)
local has_devicons, devicons = pcall(require, 'nvim-web-devicons')
local function have_icons() return has_devicons end
local function file_icon()
  if not has_devicons then return '' end
  local icon = devicons.get_icon(vim.fn.expand('%:t'), nil, { default = true })
  return icon or ''
end
-- ===========================================

require('lualine').setup({
  options = {
    theme = 'flexoki',
    globalstatus = false,
    section_separators = section_seps,
    component_separators = comp_seps,
    refresh = { statusline = 100 },
  },

  -- LEFT: [N/I/V]  [ branch]  [icon] [topdir/file]
  sections = {
    lualine_a = {
      { 'mode', fmt = tiny_mode, padding = { left = 1, right = 1 } },
    },
    lualine_b = {
      { 'branch', icon = '', color = { gui = 'bold' }, cond = winwide(50) },
    },
    lualine_c = {
      -- icon as its own component (string-returning function)
      --{ file_icon, cond = have_icons, padding = { left = 1, right = 0 } },
      -- filename/path component
      {
        function() return top_dir_plus_file() end,
        color = { gui = 'bold' },
        padding = { left = 1, right = 1 },
      },
    },

    -- RIGHT: [diagnostics] [filetype icon-only] [encoding if not utf-8] [line:col]
    lualine_x = {
      { 'diagnostics', cond = winwide(70), padding = 0 },
      { 'filetype', icon_only = true, colored = true, padding = { left = 1, right = 0 }, cond = winwide(60) },
      {
        function()
          local enc = (vim.bo.fenc ~= '' and vim.bo.fenc) or vim.o.enc
          return enc
        end,
        cond = not_utf8,
        padding = { left = 1, right = 0 },
      },
    },
    lualine_y = {
      { 'progress', cond = winwide(90), padding = 0 },
    },
    lualine_z = {
      { 'location', padding = 0 },
    },
  },

  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {
      { file_icon, cond = have_icons, padding = { left = 1, right = 0 } },
      { function() return top_dir_plus_file() end, padding = { left = 1, right = 1 } },
    },
    lualine_x = {
      { 'location', padding = 0 },
    },
    lualine_y = {},
    lualine_z = {},
  },
})

