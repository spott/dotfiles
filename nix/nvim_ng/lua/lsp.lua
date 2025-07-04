local capabilities = require('cmp_nvim_lsp').default_capabilities()
local lspconfig = require("lspconfig")
local util = require("lspconfig.util")

lspconfig.efm.setup {
  autostart = true,
  init_options = { documentFormatting = true },
  settings = {
    rootMarkers = { ".git/" },
    languages = {
      python = {
        require('efmls-configs.formatters.ruff'),
        require('efmls-configs.formatters.ruff_sort'),
        require('efmls-configs.linters.ruff'),
      },
      nix = {
        require('efmls-configs.formatters.alejandra'),
      },
    }
  }
}

lspconfig.ty.setup {
  cmd = { "ty", "server" },
  filetypes={"python"},
  root_dir = util.root_pattern("pyproject.toml",".git"),
}

lspconfig.basedpyright.setup {
  autostart = true,
  capabilities = capabilities,
  settings = {
    basedpyright = {
      analysis = {
        autoImportCompletions = true,
        autoSearchPaths = true,
        diagnosticMode = "openFilesOnly",
        useLibraryCodeForTypes = true,
        inlayHints = {
          variableTypes = true,
          callArgumentNames = true,
          functionReturnTypes = true
        },
        typeCheckingMode = "standard"
      }
    }
  }
}

lspconfig.lua_ls.setup {
  autostart = true,
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {'vim'},
      },
    },
  },
}

lspconfig.jsonls.setup { autostart = true, capabilities = capabilities }
lspconfig.terraform_lsp.setup { autostart = true, capabilities = capabilities }



lspconfig.nil_ls.setup {
  autostart = true,
  capabilities = capabilities,
  cmd = { 'nil' },
  settings = {
    ['nil'] = {
      formatting = {
        command = { "alejandra" },
      },
    },
  },
}
-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<space>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<space>f', function()
      vim.lsp.buf.format { async = true }
    end, opts)
  end,
})

-- local lsp_mappings = {
--     { 'gD', vim.lsp.buf.declaration },
--     { 'gd', vim.lsp.buf.definition },
--     { 'gi', vim.lsp.buf.implementation },
--     { 'gr', vim.lsp.buf.references },
--     -- { '[d', vim.diagnostic.goto_prev },
--     -- { ']d', vim.diagnostic.goto_next },
--     -- { ' ' , vim.lsp.buf.hover },
--     -- { ' s', vim.lsp.buf.signature_help },
--     -- { ' d', vim.diagnostic.open_float },
--     -- { ' q', vim.diagnostic.setloclist },
--     -- { '\\r', vim.lsp.buf.rename },
--     -- { '\\a', vim.lsp.buf.code_action },
--   }
-- for i, map in pairs(lsp_mappings) do
--   vim.keymap.set('n', map[1], function() map[2]() end)
-- end
