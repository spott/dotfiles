require("supermaven-nvim").setup({
  keymaps = {
    accept_suggestion = "<Tab>",
    clear_suggestion = "<C-]>",
    accept_word = "<C-j>",
  },
  -- ignore_filetypes = { },
  -- color = {
  --   suggestion_color = "#ffffff",
  --   cterm = 244,
  -- },
  -- log_level = "info", -- set to "off" to disable logging completely
  -- disable_inline_completion = false, -- disables inline completion for use with cmp
  -- disable_keymaps = false, -- disables built in keymaps for more manual control
  -- condition = function()
  --   return false
  -- end -- condition to check for stopping supermaven, `true` means to stop supermaven when the condition is true.
})

vim.keymap.set('n', '<leader>sm', function()
  local api = require("supermaven-nvim.api")
  if api.is_running() then
    api.stop()
    vim.notify("Supermaven disabled", vim.log.levels.INFO)
  else
    api.start()
    vim.notify("Supermaven enabled", vim.log.levels.INFO)
  end
end, { desc = "Toggle Supermaven", silent = true })
