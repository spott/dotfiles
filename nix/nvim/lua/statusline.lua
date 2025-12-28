-- ================= helpers =================
local uv = vim.uv or vim.loop

local function project_root()
  -- Prefer LSP root
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
    local root = client.config and client.config.root_dir
    if root and root ~= '' then return root end
  end
  -- Else Git toplevel (one-shot, NOT in draw path)
  local ok, toplevel = pcall(function()
    local dir = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':h')
    return vim.fn.systemlist('git -C ' .. vim.fn.shellescape(dir) .. ' rev-parse --show-toplevel')[1]
  end)
  if ok and toplevel and toplevel ~= '' then return toplevel end
  return uv.cwd()
end

local function smart_path_tail(rel)
  -- Always keep last two path components; keep more from the left if there is room
  local parts = {}
  for seg in rel:gmatch('[^/]+') do
    parts[#parts + 1] = seg
  end

  -- 0/1/2 components: nothing fancy needed
  if #parts <= 2 then
    return rel
  end

  -- Rough max length based on window width (tune the constant if you like)
  local win = vim.fn.winwidth(0)
  local max_len = math.max(20, win - 30)

  -- Start with last two components
  local res = { parts[#parts - 1], parts[#parts] }
  local len = #res[1] + 1 + #res[2] -- "dir/file"

  -- Try to prepend earlier components while there is room
  local i = #parts - 2
  while i >= 1 do
    local seg = parts[i]
    local new_len = #seg + 1 + len -- "seg/...existing..."
    local extra = 2                -- room for "…/"
    if new_len + extra > max_len then
      break
    end
    table.insert(res, 1, seg)
    len = new_len
    i = i - 1
  end

  if i >= 1 then
    -- We had to drop some leading components
    return '…/' .. table.concat(res, '/')
  else
    -- We kept everything
    return table.concat(res, '/')
  end
end

local function top_dir_plus_file()
  local full = vim.api.nvim_buf_get_name(0)
  if full == '' then
    return '[No Name]'
  end

  local root = project_root()
  local rel
  if root and full:sub(1, #root) == root then
    rel = full:sub(#root + 2) -- strip "<root>/"
  else
    -- Outside project root: just use filename, nothing to shorten
    rel = vim.fn.fnamemodify(full, ':t')
  end

  return smart_path_tail(rel)
end

local function tiny_mode(m)
  m = (m or ''):upper()
  local map = {
    NORMAL = 'N',
    INSERT = 'I',
    VISUAL = 'V',
    ['V-LINE'] = 'V',
    ['V-BLOCK'] = 'V',
    SELECT = 'S',
    ['S-LINE'] = 'S',
    ['S-BLOCK'] = 'S',
    REPLACE = 'R',
    ['V-REPLACE'] = 'R',
    COMMAND = 'C',
    EX = 'X',
    MORE = 'M',
    CONFIRM = '?',
    SHELL = '!',
    TERM = 'T'
  }
  return map[m] or (m:sub(1, 1) ~= '' and m:sub(1, 1) or '?')
end

local function not_utf8()
  local enc = (vim.bo.fenc ~= '' and vim.bo.fenc) or vim.o.enc
  return (enc or ''):lower() ~= 'utf-8'
end

local function winwide(min)
  return function() return vim.fn.winwidth(0) >= (min or 80) end
end

-- -------- Theme-aware colors (resilient) --------
local function hl_safe(name)
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
  return ok and hl or {}
end

local function hex_or_nil(n) return n and string.format('#%06x', n) or nil end

-- Try several groups for fg/bg; fall back smartly
local function pick_fg(groups, fallback)
  for _, g in ipairs(groups) do
    local c = hex_or_nil(hl_safe(g).fg)
    if c then return c end
  end
  return fallback
end

local function pick_bg()
  return pick_fg({ 'StatusLine' }, nil) -- actually asking for bg below
end

-- bg (prefer StatusLine, else Normal, else white/black)
local function get_bg()
  local s = hl_safe('StatusLine').bg or hl_safe('Normal').bg
  if s then return string.format('#%06x', s) end
  return (vim.o.background == 'light') and '#ffffff' or '#000000'
end

-- simple contrast booster (darken on light bg, lighten on dark bg)
local function boost_contrast(fg, bg)
  if not fg or not bg then return fg end
  local function to_rgb(h) return tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16) end
  local fr, fgc, fb = to_rgb(fg); local br, bg_, bb = to_rgb(bg)
  local bg_is_light = (0.2126 * br + 0.7152 * bg_ + 0.0722 * bb) > 127
  local factor = bg_is_light and 0.75 or 1.25 -- darken a bit on light bg; lighten on dark
  local nr = math.max(0, math.min(255, math.floor(fr * factor)))
  local ng = math.max(0, math.min(255, math.floor(fgc * factor)))
  local nb = math.max(0, math.min(255, math.floor(fb * factor)))
  return string.format('#%02x%02x%02x', nr, ng, nb)
end

local BG = get_bg()

local COLORS = {
  -- Clean “OK” tone (try GitSignsAdd/DiffAdd/String/Identifier)
  clean         = boost_contrast(pick_fg({ 'GitSignsAdd', 'DiffAdd', 'String', 'Identifier' }, '#2e7d32'), BG),

  -- Strong red for errors/dirty file
  dirtyF        = boost_contrast(pick_fg({ 'DiagnosticError', 'ErrorMsg', 'Error', 'DiffDelete' }, '#b00020'), BG),

  -- Amber/yellow for repo dirty
  dirtyR        = boost_contrast(pick_fg({ 'DiagnosticWarn', 'WarningMsg', 'Todo' }, '#b36b00'), BG),

  -- Filename (clean): prefer StatusLine fg or Normal fg
  fnameM        = boost_contrast(pick_fg({ 'StatusLine', 'Normal', 'Title' }, '#1e293b'), BG),

  -- Filename (modified): reuse dirty red
  fnameD        = boost_contrast(pick_fg({ 'DiagnosticError', 'ErrorMsg', 'Error' }, '#b00020'), BG),

  -- "Black" when clean: prefer Normal fg, else hard black
  fnameNC_clean = boost_contrast(
    pick_fg({ 'StatusLineNC', 'Normal' }, '#000000'),
    BG
  ),
  -- Muted red when modified: darker fallback than active dirty red
  fnameNC_dirty = boost_contrast(
    pick_fg({ 'DiagnosticWarn', 'DiffText' }, '#7f1d1d'),
    BG
  ),
}
-- -----------------------------------------------

local function stl_bufnr()
  local winid = vim.g.statusline_winid
  if winid and winid ~= 0 then
    return vim.api.nvim_win_get_buf(winid)
  end
  return vim.api.nvim_get_current_buf()
end

local function stl_modified()
  local bufnr = stl_bufnr()
  local ok, modified = pcall(function()
    return vim.bo[bufnr].modified
  end)
  if ok then
    return modified
  end
  return vim.bo.modified
end


-- devicons (optional)
local has_devicons, devicons = pcall(require, 'nvim-web-devicons')
local function have_icons() return has_devicons end
local function file_icon()
  if not has_devicons then return '' end
  local icon = devicons.get_icon(vim.fn.expand('%:t'), nil, { default = true })
  return icon or ''
end

-- ================= Dirtiness (async + cached, zero work in draw) =============
local has_gitsigns, _gitsigns = pcall(require, 'gitsigns')

-- File dirty vs HEAD:
--   * If gitsigns is present => use its per-buffer counts (instant)
--   * Else => use unsaved buffer state (no shelling on draw)
local function file_dirty_vs_head()
  if has_gitsigns and vim.b.gitsigns_status_dict then
    local d = vim.b.gitsigns_status_dict
    local a = tonumber(d.added or 0) or 0
    local c = tonumber(d.changed or 0) or 0
    local r = tonumber(d.removed or 0) or 0
    return (a + c + r) > 0
  end
  return vim.bo.modified or false
end

-- Repo dirty cached per root, updated asynchronously via jobstart
local CURRENT_ROOT = nil
local RepoCache = {} -- [root] = { dirty=bool, running=bool, last=ms }

-- determine/remember current root on safe events (not in draw path)
local function update_current_root()
  CURRENT_ROOT = project_root()
end

-- schedule async scan; safe to call often: guarded by 'running' flag
local function schedule_repo_scan(root)
  if not root then return end
  local entry = RepoCache[root] or {}
  if entry.running then return end
  entry.running = true
  RepoCache[root] = entry
  vim.fn.jobstart({ 'git', '-C', root, 'status', '--porcelain', '-uno' }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      local dirty = false
      if data then
        for _, l in ipairs(data) do
          if l and l ~= '' then
            dirty = true; break
          end
        end
      end
      entry.dirty = dirty
    end,
    on_exit = function()
      entry.running = false
      entry.last = (uv.now and uv.now() or 0)
      local ok, lualine = pcall(require, 'lualine')
      if ok then lualine.refresh() end
    end,
  })
end

-- read-only in draw path; may opportunistically trigger a scan
local function repo_is_dirty()
  local root = CURRENT_ROOT
  if not root then return false end
  local entry = RepoCache[root]
  if not entry then
    -- Kick off first scan; assume clean until we know
    schedule_repo_scan(root)
    return false
  end
  return entry.dirty or false
end

-- Keep repo status fresh on meaningful events
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'FocusGained' }, {
  callback = function()
    update_current_root()
    if CURRENT_ROOT then schedule_repo_scan(CURRENT_ROOT) end
  end,
})

-- ================= separators (static; no idle thrash) =======================
local section_seps = (vim.o.columns >= 100) and { left = '', right = '' } or { left = '', right = '' }
local comp_seps    = (vim.o.columns >= 100) and { left = '|', right = '|' } or { left = '', right = '' }

-- ===========================================
require('lualine').setup({
  options = {
    theme = 'flexoki',
    globalstatus = false,
    section_separators = section_seps,
    component_separators = comp_seps,
    -- No aggressive refresh; let lualine decide
  },

  -- LEFT: [N/I/V]  [ icon colored by FILE dirty]  [branch name colored by REPO dirty]  [smart path colored by buffer modified]
  sections = {
    lualine_a = {
      { 'mode', fmt = tiny_mode, padding = { left = 1, right = 1 } },
    },

    lualine_b = {
      -- Branch ICON (colored by single-file dirty; zero-cost)
      {
        function() return '' end,
        color = function()
          return { fg = file_dirty_vs_head() and COLORS.dirtyF or COLORS.clean, gui = 'bold' }
        end,
        padding = { left = 1, right = 0 },
        cond = winwide(50),
      },
      -- Branch NAME (colored by repo dirty; async-cached)
      {
        'branch',
        icon = '',
        color = function()
          return { fg = repo_is_dirty() and COLORS.dirtyR or COLORS.clean, gui = 'bold' }
        end,
        padding = { left = 1, right = 1 },
        cond = winwide(50),
      },
    },

    lualine_c = {
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
      { 'filetype',    icon_only = true,   colored = true, padding = { left = 1, right = 0 }, cond = winwide(60) },
      {
        function()
          local enc = (vim.bo.fenc ~= '' and vim.o.fenc) or vim.o.enc
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
      -- If you want the icon, uncomment the next line:
      -- { function() return file_icon() end, cond = have_icons, padding = { left = 1, right = 0 } },
      {
        function() return top_dir_plus_file() end,
        color = function()
          if stl_modified() then
            return { fg = COLORS.fnameNC_dirty, gui = 'bold' }
          else
            return { fg = COLORS.fnameNC_clean, gui = 'bold' }
          end
        end,
        padding = { left = 1, right = 1 },
      },
    },
    lualine_x = { { 'location', padding = 0 } },
    lualine_y = {},
    lualine_z = {},
  },
})

-- Optional: if you want to absolutely stop cursor "blink reset" at idle:
-- vim.o.showmode = false
-- vim.opt.guicursor:append('a:blinkon0')
