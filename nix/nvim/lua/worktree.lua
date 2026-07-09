-- Git worktree switching with buffer remapping and Python env handling.
-- Built on git-worktree.nvim (polarmutex fork); worktrees typically live in
-- .claude/worktrees/ but any `git worktree list` location works.

vim.g.git_worktree = {
  change_directory_command = 'cd',
  clearjumps_on_change = true,
  confirm_telescope_deletions = true,
}

require('telescope').load_extension('git_worktree')

local Hooks = require('git-worktree.hooks')

local function git(args, cwd)
  local result = vim.system(vim.list_extend({ 'git', '-C', cwd }, args), { text = true }):wait()
  if result.code ~= 0 then
    return nil
  end
  return vim.trim(result.stdout)
end

-- Root of the main checkout for the repo containing `dir`, or nil (bare repo,
-- not a repo). For linked worktrees --git-common-dir still points at the main
-- checkout's .git directory.
local function main_root(dir)
  local common = git({ 'rev-parse', '--path-format=absolute', '--git-common-dir' }, dir)
  if not common or not common:match('/%.git$') then
    return nil
  end
  return vim.fs.normalize((common:gsub('/%.git$', '')))
end

local function worktree_root(dir)
  local top = git({ 'rev-parse', '--show-toplevel' }, dir)
  return top and vim.fs.normalize(top) or nil
end

-- Re-point every clean file buffer under the old worktree at the same
-- relative path in the new one. Modified buffers and files missing from the
-- target are left alone; window layout and cursors are preserved.
local function remap_buffers(path, prev_path)
  -- prev_path is the pre-switch cwd, which may be a subdirectory
  prev_path = worktree_root(prev_path) or vim.fs.normalize(prev_path)
  path = vim.fs.normalize(path)
  if prev_path == path then
    return
  end

  local remapped, skipped_modified, skipped_missing = 0, {}, {}

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    repeat
      if not vim.api.nvim_buf_is_loaded(buf)
          or not vim.bo[buf].buflisted
          or vim.bo[buf].buftype ~= '' then
        break
      end
      local name = vim.api.nvim_buf_get_name(buf)
      if name == '' then
        break
      end
      name = vim.fs.normalize(name)
      if name:sub(1, #prev_path + 1) ~= prev_path .. '/' then
        break
      end
      local rel = name:sub(#prev_path + 2)
      local target = path .. '/' .. rel
      if not vim.uv.fs_stat(target) then
        table.insert(skipped_missing, rel)
        break
      end
      if vim.bo[buf].modified then
        table.insert(skipped_modified, rel)
        break
      end

      local newbuf = vim.fn.bufadd(target)
      vim.fn.bufload(newbuf)
      vim.bo[newbuf].buflisted = true
      for _, win in ipairs(vim.fn.win_findbuf(buf)) do
        local cur = vim.api.nvim_win_get_cursor(win)
        vim.api.nvim_win_set_buf(win, newbuf)
        local lines = vim.api.nvim_buf_line_count(newbuf)
        pcall(vim.api.nvim_win_set_cursor, win, { math.min(cur[1], lines), cur[2] })
      end
      vim.api.nvim_buf_delete(buf, { force = false })
      remapped = remapped + 1
    until true
  end

  local msg = ('worktree: remapped %d buffer(s)'):format(remapped)
  local details = {}
  if #skipped_modified > 0 then
    table.insert(details, 'modified: ' .. table.concat(skipped_modified, ', '))
  end
  if #skipped_missing > 0 then
    table.insert(details, 'missing: ' .. table.concat(skipped_missing, ', '))
  end
  if #details > 0 then
    msg = msg .. (', skipped %d (%s)'):format(#skipped_modified + #skipped_missing, table.concat(details, '; '))
  end
  vim.notify(msg, vim.log.levels.INFO)
end

-- Environment as it was before the first switch; every switch rebuilds from
-- these so round-trips never stack PATH/PYTHONPATH entries.
local original = nil

local function capture_original()
  if not original then
    original = {
      PYTHONPATH = vim.env.PYTHONPATH,
      PATH = vim.env.PATH,
      VIRTUAL_ENV = vim.env.VIRTUAL_ENV,
    }
  end
end

-- Keep the main checkout's venv (interpreter + deps) but put the worktree's
-- sources first on PYTHONPATH so they shadow the editable install of the main
-- checkout. vim.env mutates nvim's own environment, so :terminal, neotest
-- jobs, and the DAP debuggee all inherit this.
local function apply_python_env(path)
  capture_original()
  path = vim.fs.normalize(path)
  local root = main_root(path)
  if not root then
    vim.notify('worktree: could not determine main checkout; leaving Python env untouched', vim.log.levels.WARN)
    return
  end

  local venv = root .. '/.venv'
  if vim.uv.fs_stat(venv) then
    vim.env.VIRTUAL_ENV = venv
    vim.env.PATH = venv .. '/bin' .. (original.PATH and (':' .. original.PATH) or '')
  end
  -- else: leave VIRTUAL_ENV alone (poetry venvs live in the cache dir and are
  -- already exported by direnv when nvim started)

  if path == root then
    vim.env.PYTHONPATH = original.PYTHONPATH
  else
    local parts = {}
    if vim.uv.fs_stat(path .. '/src') then
      table.insert(parts, path .. '/src')
    end
    table.insert(parts, path)
    if original.PYTHONPATH and original.PYTHONPATH ~= '' then
      table.insert(parts, original.PYTHONPATH)
    end
    vim.env.PYTHONPATH = table.concat(parts, ':')
  end
end

local function restart_python_lsps()
  local names = { 'ty', 'ruff' }
  vim.lsp.enable(names, false)
  -- fallback in case disable doesn't stop running clients on this nvim version
  for _, name in ipairs(names) do
    for _, client in ipairs(vim.lsp.get_clients({ name = name })) do
      client:stop(true)
    end
  end
  vim.defer_fn(function()
    vim.lsp.enable(names, true)
  end, 150)
end

Hooks.register(Hooks.type.SWITCH, function(path, prev_path)
  remap_buffers(path, prev_path)
  apply_python_env(path)
  restart_python_lsps()
end)

Hooks.register(Hooks.type.DELETE, function(deleted_path)
  local cwd = vim.fs.normalize(vim.uv.cwd() or '')
  deleted_path = vim.fs.normalize(deleted_path)
  if cwd == deleted_path or cwd:sub(1, #deleted_path + 1) == deleted_path .. '/' then
    local root = main_root(cwd) or vim.fs.dirname(deleted_path)
    require('git-worktree').switch_worktree(root)
  end
end)

local M = {}

-- Create a worktree under <main root>/.claude/worktrees/<branch>. Absolute
-- path matters: the plugin resolves relative paths against cwd, not git root.
function M.create_claude_worktree()
  local root = main_root(vim.uv.cwd() or '')
  if not root then
    vim.notify('worktree: not in a git repository', vim.log.levels.ERROR)
    return
  end
  vim.ui.input({ prompt = 'New worktree branch: ' }, function(branch)
    if not branch or branch == '' then
      return
    end
    require('git-worktree').create_worktree(root .. '/.claude/worktrees/' .. branch, branch)
  end)
end

function M.switch_to_main()
  local root = main_root(vim.uv.cwd() or '')
  if not root then
    vim.notify('worktree: not in a git repository', vim.log.levels.ERROR)
    return
  end
  if worktree_root(vim.uv.cwd() or '') == root then
    vim.notify('worktree: already in the main checkout', vim.log.levels.INFO)
    return
  end
  require('git-worktree').switch_worktree(root)
end

vim.keymap.set('n', '<leader>gww', function()
  require('telescope').extensions.git_worktree.git_worktree()
end, { desc = 'Worktrees (switch / <M-d> delete)' })
vim.keymap.set('n', '<leader>gwc', M.create_claude_worktree, { desc = 'Create worktree in .claude/worktrees' })
vim.keymap.set('n', '<leader>gwC', function()
  require('telescope').extensions.git_worktree.create_git_worktree()
end, { desc = 'Create worktree (custom path)' })
vim.keymap.set('n', '<leader>gwm', M.switch_to_main, { desc = 'Switch to main checkout' })

return M
