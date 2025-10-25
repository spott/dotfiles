-- ================= helpers =================
local uv = vim.uv or vim.loop

local function project_root()
  -- Prefer LSP root
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
    local root = client.config and client.config.root_dir
    if root and root ~= '' then return root end
  end
  -- Else Git toplevel
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

-- Grab fg from a highlight group if possible (fallback to hex)
local function hl_fg(name, fallback)
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
  if ok and hl and hl.fg then
    return string.format('#%06x', hl.fg)
  end
  return fallback
end

-- A small palette that tries to respect your colorscheme via hl groups
local COLORS = {
  clean  = hl_fg('DiffAdd',        '#8ec07c'),
  dirtyF = hl_fg('DiagnosticError','#fb4934'), -- file dirty (icon)
  dirtyR = hl_fg('DiagnosticWarn', '#fabd2f'), -- repo dirty (branch name)
  fnameM = hl_fg('String',         '#a7c080'), -- clean filename
  fnameD = hl_fg('DiagnosticError','#e67e80'), -- modified buffer
}

-- Git helpers (fast when gitsigns is available)
local has_gitsigns, gitsigns = pcall(require, 'gitsigns')
local file_dirty_cache = { path = nil, ts = 0, dirty = false }
local repo_dirty_cache = { root = nil, ts = 0, dirty = false }
local CACHE_TTL = 1.0 -- seconds

local function buf_abs_path()
  local p = vim.api.nvim_buf_get_name(0)
  return p ~= '' and p or nil
end

local function git_root_for_buf()
  local path = buf_abs_path()
  if not path then return nil end
  local dir = vim.fn.fnamemodify(path, ':h')
  local top = vim.fn.systemlist('git -C ' .. vim.fn.shellescape(dir) .. ' rev-parse --show-toplevel')[1]
  if top and top ~= '' and vim.v.shell_error == 0 then return top end
  return nil
end

-- Is current file dirty vs HEAD?
local function is_file_dirty()
  local path = buf_abs_path()
  if not path then return false end

  -- cache
  local now = uv.now() / 1000
  if file_dirty_cache.path == path and (now - file_dirty_cache.ts) < CACHE_TTL then
    return file_dirty_cache.dirty
  end

  local dirty = false
  if has_gitsigns and vim.b.gitsigns_status_dict then
    local d = vim.b.gitsigns_status_dict
    local added = tonumber(d.added or 0) or 0
    local changed = tonumber(d.changed or 0) or 0
    local removed = tonumber(d.removed or 0) or 0
    dirty = (added + changed + removed) > 0
  else
    local root = git_root_for_buf()
    if root then
      local rel = vim.fn.fnamemodify(path, ':~:.')
      local out = vim.fn.systemlist('git -C ' .. vim.fn.shellescape(root)
        .. ' status --porcelain -- ' .. vim.fn.shellescape(path))
      dirty = out and #out > 0
    end
  end

  file_dirty_cache = { path = path, ts = now, dirty = dirty }
  return dirty
end

-- Is repo dirty (any file changed)?
local function is_repo_dirty()
  local root = git_root_for_buf()
  if not root then return false end

  local now = uv.now() / 1000
  if repo_dirty_cache.root == root and (now - repo_dirty_cache.ts) < CACHE_TTL then
    return repo_dirty_cache.dirty
  end

  local dirty = false
  if has_gitsigns and gitsigns.get_repo_status then
    -- Some gitsigns versions expose repo info; fall back to porcelain anyway
    local out = vim.fn.systemlist('git -C ' .. vim.fn.shellescape(root) .. ' status --porcelain -uno')
    dirty = out and #out > 0
  else
    local out = vim.fn.systemlist('git -C ' .. vim.fn.shellescape(root) .. ' status --porcelain -uno')
    dirty = out and #out > 0
  end

  repo_dirty_cache = { root = root, ts = now, dirty = dirty }
  return dirty
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
    -- refresh = { statusline = 100 },
  },

  -- LEFT: [N/I/V]  [ icon colored by FILE dirty]  [branch name colored by REPO dirty]  [file icon] [smart path colored by buffer modified]
  sections = {
    lualine_a = {
      { 'mode', fmt = tiny_mode, padding = { left = 1, right = 1 } },
    },

    -- Branch bits live in lualine_b
    lualine_b = {
      -- Branch ICON (colored by single-file dirty)
      {
        function() return '' end,
        color = function()
          return { fg = is_file_dirty() and COLORS.dirtyF or COLORS.clean, gui = 'bold' }
        end,
        padding = { left = 1, right = 0 },
        cond = winwide(50),
      },
      -- Branch NAME (colored by repo dirty)
      {
        'branch',
        icon = '', -- no icon; we render it separately
        color = function()
          return { fg = is_repo_dirty() and COLORS.dirtyR or COLORS.clean, gui = 'bold' }
        end,
        padding = { left = 1, right = 1 },
        cond = winwide(50),
      },
    },

    lualine_c = {
      --{ file_icon, cond = have_icons, padding = { left = 1, right = 0 } },
      {
        function() return top_dir_plus_file() end,
        color = function()
          return { fg = (vim.bo.modified and COLORS.fnameD or COLORS.fnameM), gui = 'bold' }
        end,
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
      {
        function() return top_dir_plus_file() end,
        color = function()
          return { fg = (vim.bo.modified and COLORS.fnameD or COLORS.fnameM), gui = 'bold' }
        end,
        padding = { left = 1, right = 1 },
      },
    },
    lualine_x = { { 'location', padding = 0 } },
    lualine_y = {},
    lualine_z = {},
  },
})

-- Optional: refresh caches when you save or change buffers (keeps colors snappy)
vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufEnter', 'FocusGained' }, {
  callback = function()
    file_dirty_cache.ts = 0
    repo_dirty_cache.ts = 0
  end,
})

