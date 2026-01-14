local dap = require('dap')
local dapui = require('dapui')

-- Virtual text for inline values
require('nvim-dap-virtual-text').setup({
  -- Show terse inline values; special handling for NumPy ndarrays.
  display_callback = function(variable, buf, stackframe, node, options)
    local value = tostring(variable.value or "")
    local vtype = tostring(variable.type or ""):lower()

    -- Heuristics to detect numpy arrays from debugpy’s info
    local is_numpy =
      vtype:find("ndarray", 1, true)
      or vtype:find("numpy", 1, true)
      or value:match("^%s*array%(")
      or value:find("dtype=", 1, true)
      or value:find("shape=(", 1, true)

    if is_numpy then
      -- Try to extract shape / dtype from the adapter’s preview text
      local shape = value:match("shape=%(([^)]*)%)") or vtype:match("%(([^)]*)%)")
      local dtype = value:match("dtype=([%w_%.%-]+)")

      if shape or dtype then
        local parts = {}
        table.insert(parts, "ndarray[")
        if shape then table.insert(parts, "shape=(" .. shape .. ")") end
        if dtype then table.insert(parts, "dtype=" .. dtype) end
        table.insert(parts, "]")
        value = table.concat(parts, " ")
      else
        -- Fallback if adapter didn’t include shape/dtype; keep it minimal
        value = "ndarray[…]"
      end
    end

    -- Hard cap: 40 characters for ANY variable preview
    local maxlen = 40
    if #value > maxlen then
      value = value:sub(1, maxlen - 3) .. "..."
    end
    return value
  end,
})

-- Nice panes for scopes/breakpoints/stacks/repl
dapui.setup({
  -- minimal defaults are fine; customize icons/layouts later
})

-- Auto-open/close DAP UI
dap.listeners.after.event_initialized['dapui_config'] = function() dapui.open() end
dap.listeners.before.event_terminated['dapui_config']  = function() dapui.close() end
dap.listeners.before.event_exited['dapui_config']      = function() dapui.close() end

-- Python adapter via nvim-dap-python
local dap_python = require('dap-python')
local py = vim.env.DAP_PYTHON or 'python3'
dap_python.setup(py)
dap_python.test_runner = 'pytest'   -- integrate with pytest

-- ---- Child debugpy attach config ----
local CHILD_HOST = "127.0.0.1"
local CHILD_PORT = 5679

dap.configurations.python = dap.configurations.python or {}

table.insert(dap.configurations.python, {
  type = "python",
  request = "attach",
  name = "Attach to child (debugpy)",
  connect = { host = CHILD_HOST, port = CHILD_PORT },
  justMyCode = false,
})

-- Handy keymaps (kept close to DAP so they don’t depend on LspAttach)
local map = vim.keymap.set
local opts = { noremap = true, silent = true, desc = '' }

map('n', '<leader>dc',  dap.continue,              vim.tbl_extend('force', opts, { desc = 'DAP Continue/Start' }))
-- map('n', '<F10>', dap.step_over,             vim.tbl_extend('force', opts, { desc = 'DAP Step Over' }))
-- map('n', '<F11>', dap.step_into,             vim.tbl_extend('force', opts, { desc = 'DAP Step Into' }))
-- map('n', '<F12>', dap.step_out,              vim.tbl_extend('force', opts, { desc = 'DAP Step Out' }))
map('n', '<leader>db', dap.toggle_breakpoint,vim.tbl_extend('force', opts, { desc = 'DAP Toggle Breakpoint' }))
map('n', '<leader>dB', function()
  dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
end,                                           vim.tbl_extend('force', opts, { desc = 'DAP Conditional Breakpoint' }))
map('n', '<leader>dl', dap.run_last,         vim.tbl_extend('force', opts, { desc = 'DAP Run Last' }))
map('n', '<leader>dr', dap.repl.open,        vim.tbl_extend('force', opts, { desc = 'DAP REPL' }))
map('n', '<leader>du', dapui.toggle,         vim.tbl_extend('force', opts, { desc = 'DAP UI Toggle' }))

-- Convenience: debug current test (method/class) via dap-python
map('n', '<leader>dtm', dap_python.test_method, vim.tbl_extend('force', opts, { desc = 'Debug test (method)' }))
map('n', '<leader>dtc', dap_python.test_class,  vim.tbl_extend('force', opts, { desc = 'Debug tests (class/file)' }))
map('v', '<leader>dts', dap_python.debug_selection, vim.tbl_extend('force', opts, { desc = 'Debug selection' }))

-- Tip from nvim-dap README: Down=over, Right=into, Left=out, Up=restart frame
-- We'll install them on session start and remove them when the session ends.
local function _dap_set_arrow_maps()
  local o = { noremap = true, silent = true }
  vim.keymap.set('n', '<Down>',  dap.step_over, vim.tbl_extend('force', o, { desc = 'DAP Step Over' }))
  vim.keymap.set('n', '<Right>', dap.step_into, vim.tbl_extend('force', o, { desc = 'DAP Step Into' }))
  vim.keymap.set('n', '<Left>',  dap.step_out,  vim.tbl_extend('force', o, { desc = 'DAP Step Out' }))
  vim.keymap.set('n', '<Up>', function()
    -- Prefer Restart Frame (added in nvim-dap Mar 26, 2025); fall back to session restart.
    if not pcall(dap.restart_frame) then
      -- fallbacks if the adapter doesn't support restartFrame
      if not pcall(dap.restart) then
        pcall(dap.terminate)
        pcall(dap.run_last)
      end
    end
  end, vim.tbl_extend('force', o, { desc = 'DAP Restart Frame / Restart' }))
end

local function _dap_del_arrow_maps()
  pcall(vim.keymap.del, 'n', '<Down>')
  pcall(vim.keymap.del, 'n', '<Right>')
  pcall(vim.keymap.del, 'n', '<Left>')
  pcall(vim.keymap.del, 'n', '<Up>')
end

-- Use listeners so the maps exist only while debugging
dap.listeners.after.event_initialized['user.arrowmaps'] = _dap_set_arrow_maps
dap.listeners.before.event_terminated['user.arrowmaps'] = _dap_del_arrow_maps
dap.listeners.before.event_exited['user.arrowmaps']      = _dap_del_arrow_maps

-- ---- <leader>df: Run "this file" with cwd = this file's directory ----
-- Python-first (uses nvim-dap-python defaults), but will try a generic launch
-- config for other filetypes if one exists.
vim.keymap.set('n', '<leader>df', function()
  local file = vim.fn.expand('%:p')
  local cwd  = vim.fn.fnamemodify(file, ':h')
  local ft   = vim.bo.filetype

  if ft == 'python' then
    dap.run({
      type = 'python',
      request = 'launch',
      name = 'Debug current file (cwd=file dir)',
      program = file,
      cwd = cwd,
      justMyCode = false,
      console = 'integratedTerminal',
    })
    return
  end

  -- Generic best-effort: reuse the first 'launch' config for this ft.
  local cfgs = dap.configurations[ft] or {}
  for _, cfg in ipairs(cfgs) do
    if cfg.request == 'launch' then
      local run_cfg = vim.deepcopy(cfg)
      run_cfg.program = run_cfg.program or file
      run_cfg.cwd     = run_cfg.cwd     or cwd
      dap.run(run_cfg)
      return
    end
  end
  vim.notify('No DAP launch configuration for filetype: ' .. ft, vim.log.levels.WARN)
end, { noremap = true, silent = true, desc = 'DAP: run file here (<leader>df)' })

vim.keymap.set('n', '<leader>dJ', function()
  local file = vim.fn.expand('%:p')
  local cwd  = vim.fn.fnamemodify(file, ':h')
  local ft   = vim.bo.filetype

  if ft == 'python' then
    dap.run({
      type = 'python',
      request = 'launch',
      name = 'Debug current file (cwd=file dir)',
      program = file,
      cwd = cwd,
      justMyCode = true,
      console = 'integratedTerminal',
    })
    return
  end

  -- Generic best-effort: reuse the first 'launch' config for this ft.
  local cfgs = dap.configurations[ft] or {}
  for _, cfg in ipairs(cfgs) do
    if cfg.request == 'launch' then
      local run_cfg = vim.deepcopy(cfg)
      run_cfg.program = run_cfg.program or file
      run_cfg.cwd     = run_cfg.cwd     or cwd
      dap.run(run_cfg)
      return
    end
  end
  vim.notify('No DAP launch configuration for filetype: ' .. ft, vim.log.levels.WARN)
end, { noremap = true, silent = true, desc = 'DAP: run file here and turn off just my code (<leader>dJ)' })

-- ---- <leader>dx: Kill ALL DAP sessions ----
vim.keymap.set('n', '<leader>dx', function()
  -- best-effort: terminate+disconnect every session
  for _, s in pairs(dap.sessions()) do
    pcall(function() s:request('terminate', {}, function() end) end)
    pcall(function() s:request('disconnect', { terminateDebuggee = true }, function() end) end)
  end
  -- UI will auto-close via your existing listeners
end, { noremap = true, silent = true, desc = 'DAP: kill all sessions (<leader>dx)' })


-- ---- <leader>dF: Launch parent and auto-attach child ----
vim.keymap.set("n", "<leader>dF", function()
  local file = vim.fn.expand("%:p")
  local cwd  = vim.fn.fnamemodify(file, ":h")

  local parent_cfg = {
    type = "python",
    request = "launch",
    name = "Parent (auto-attach child)",
    program = file,
    cwd = cwd,
    justMyCode = false,
    console = "integratedTerminal",
  }

  local child_cfg = {
    type = "python",
    request = "attach",
    name = "Child (debugpy)",
    connect = { host = "127.0.0.1", port = 5679 },
    justMyCode = false,
  }

  local key = "auto_attach_child_once"
  dap.listeners.after.event_initialized[key] = function(session)
    if session and session.config and session.config.name == parent_cfg.name then
      dap.listeners.after.event_initialized[key] = nil
      -- If you used --wait-for-client, schedule is enough.
      vim.schedule(function()
        dap.run(child_cfg)
      end)
      -- If your child isn't waiting, you might prefer a tiny delay:
      -- vim.defer_fn(function() dap.run(child_cfg) end, 100)
    end
  end

  dap.run(parent_cfg)
end, { noremap = true, silent = true, desc = "DAP: launch parent and auto-attach child" })

-- ---- <leader>da: Attach to child debugpy ----
vim.keymap.set("n", "<leader>da", function()
  dap.run({
    type = "python",
    request = "attach",
    name = "Attach to child (debugpy)",
    connect = { host = "127.0.0.1", port = 5679 },
    justMyCode = false,
  })
end, { noremap = true, silent = true, desc = "DAP: attach to child debugpy" })

-- dap.up/down: navigate DAP frames --
local function set_frame_nav_maps()
  local o = { noremap = true, silent = true }
  vim.keymap.set('n', '<leader>dk', function() require('dap').up() end,
    vim.tbl_extend('force', o, { desc = 'DAP: frame ↑ (up)' }))
  vim.keymap.set('n', '<leader>dj', function() require('dap').down() end,
    vim.tbl_extend('force', o, { desc = 'DAP: frame ↓ (down)' }))
end

local function del_frame_nav_maps()
  pcall(vim.keymap.del, 'n', '<leader>dk')
  pcall(vim.keymap.del, 'n', '<leader>dj')
end

dap.listeners.after.event_initialized['user.frames'] = set_frame_nav_maps
dap.listeners.before.event_terminated['user.frames'] = del_frame_nav_maps
dap.listeners.before.event_exited['user.frames']      = del_frame_nav_maps
