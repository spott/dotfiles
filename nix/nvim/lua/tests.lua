local neotest = require('neotest')

neotest.setup({
  adapters = {
    require('neotest-python')({
      -- If you want to force a Python path (useful with uv/virtualenvs), set it here.
      -- By default it will try to detect project/env automatically.
      -- python = vim.env.DAP_PYTHON,

      runner = 'pytest',
      -- Good defaults; tune as you like:
      args = { '-q' },            -- terse == '-q'
      dap = { justMyCode = false }, -- better stepping through third-party code
      pytest_discover_instances = false,
    }),
  },
  quickfix = { enabled = false }, -- use neotest output + summary instead
  discovery = { enabled = true },
  running = { concurrent = true },
  output = { open_on_run = "short" },
})

-- Keymaps
local map = vim.keymap.set
local o = { noremap = true, silent = true }

map('n', '<leader>tn', function() neotest.run.run() end,               vim.tbl_extend('force', o, { desc = 'Test: nearest' }))
map('n', '<leader>tf', function() neotest.run.run(vim.fn.expand('%')) end, vim.tbl_extend('force', o, { desc = 'Test: file' }))
map('n', '<leader>tl', neotest.run.run_last,                           vim.tbl_extend('force', o, { desc = 'Test: last' }))
map('n', '<leader>ts', neotest.summary.toggle,                         vim.tbl_extend('force', o, { desc = 'Test: summary' }))
map('n', '<leader>to', neotest.output.open,                            vim.tbl_extend('force', o, { desc = 'Test: output' }))
map('n', '<leader>td', function() neotest.run.run({ strategy = 'dap' }) end, vim.tbl_extend('force', o, { desc = 'Test: debug nearest (DAP)' }))
