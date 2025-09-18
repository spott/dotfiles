local capabilities = require('cmp_nvim_lsp').default_capabilities()

local py_root_markers = {
  "pyproject.toml", "setup.cfg", "setup.py", "requirements.txt", "ruff.toml", "uv.lock", "poetry.lock",
  ".git",
}

vim.lsp.config('ty', {
  filetypes = { "python" },
  single_file_support = true,
  settings = {
    ty = {
      inlayHints = {
        variableTypes = true,
        cellArgumentNames = true,
      },
      experimental = {
        rename = false,
      },
      diagnosticMode = 'workspace',
    },
  },
  capabilities = capabilities,
  autostart = true,
  cmd = { 'ty', 'server' },
  root_markers = py_root_markers,
})

vim.lsp.config('ruff', {
  filetypes = { "python" },
  single_file_support = true,
  settings = {
    ruff = {
      diagnosticMode = 'workspace',
    },
  },
  capabilities = capabilities,
  autostart = true,
  cmd = { 'ruff', 'server' },
  root_markers = py_root_markers,
})


local pylsp_bin = vim.env.PYLSP_BIN or "pylsp"
vim.lsp.config("pylsp", {
  single_file_support = true,
  autostart = true,
  filetypes = { "python" },
  capabilities = capabilities,
  --cmd = { 'pylsp' },
  cmd = { pylsp_bin, '-vv', '--log-file', vim.fn.stdpath('cache') .. '/pylsp.log' },
  root_markers = py_root_markers,
  settings = {
    pylsp = {
      plugins = {
        -- use Ruff for lint/fix; drop overlapping linters
        pycodestyle = { enabled = false },
        mccabe      = { enabled = false },
        pyflakes    = { enabled = false },
        pylint      = { enabled = false },
        autopep8    = { enabled = false },


        -- Ruff inside pylsp:
        ruff = {
          enabled = false,
          -- format = { enabled = true },  -- provides formatting via Ruff
          -- organizeImports = true,
        },

        -- Rope refactors (provided by pylsp-rope)
        pylsp_rope = {
          rename = true, -- enable rope rename
        },
        -- make sure competing rename providers are off
        jedi_rename = { enabled = false },
        rope_rename = { enabled = false },
        rope_autoimport = { enabled = false, completions = { enabled = false }, code_actions = { enabled = false } },
        preload = { enabled = false },
        yapf = { enabled = false },
        flake8 = { enabled = false },


        -- Jedi stays for defs/hover/completion when ty doesn't know something yet
        jedi_completion = { enabled = false, fuzzy = true },
        jedi_definition = { enabled = false },
        jedi_hover      = { enabled = false },
        jedi_symbols    = { enabled = false },
      }
    }
  }
})

vim.lsp.config('efm', {
  autostart = true,
  init_options = { documentFormatting = true },
  filetypes = { "nix" },
  settings = {
    rootMarkers = { ".git/" },
    languages = {
      -- python = {
      --   require('efmls-configs.formatters.ruff'),
      --   require('efmls-configs.formatters.ruff_sort'),
      --   require('efmls-configs.linters.ruff'),
      -- },
      nix = {
        require('efmls-configs.formatters.alejandra'),
      },
    }
  }
})
-- lspconfig.basedpyright.setup {
--   autostart = true,
--   capabilities = capabilities,
--   settings = {
--     basedpyright = {
--       analysis = {
--         autoImportCompletions = true,
--         autoSearchPaths = true,
--         diagnosticMode = "openFilesOnly",
--         useLibraryCodeForTypes = true,
--         inlayHints = {
--           variableTypes = true,
--           callArgumentNames = true,
--           functionReturnTypes = true
--         },
--         typeCheckingMode = "standard"
--       }
--     }
--   }
-- }


vim.lsp.config('lua_ls', {
  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if
          path ~= vim.fn.stdpath('config')
          and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
      then
        return
      end
    end

    client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
      runtime = {
        -- Tell the language server which version of Lua you're using (most
        -- likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
        -- Tell the language server how to find Lua modules same way as Neovim
        -- (see `:h lua-module-load`)
        path = {
          'lua/?.lua',
          'lua/?/init.lua',
        },
      },
      -- Make the server aware of Neovim runtime files
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME
          -- Depending on the usage, you might want to add additional paths
          -- here.
          -- '${3rd}/luv/library'
          -- '${3rd}/busted/library'
        }
        -- Or pull in all of 'runtimepath'.
        -- NOTE: this is a lot slower and will cause issues when working on
        -- your own configuration.
        -- See https://github.com/neovim/nvim-lspconfig/issues/3189
        -- library = {
        --   vim.api.nvim_get_runtime_file('', true),
        -- }
      }
    })
  end,
  settings = {
    Lua = {}
  }
})

vim.lsp.config("nil_ls", {
  autostart = true,
  capabilities = capabilities,
  filetypes = { "nix" },
  cmd = { 'nil' },
  settings = {
    ['nil'] = {
      formatting = {
        command = { "alejandra" },
      },
    },
  },
})

-- Note, these should be enabled after the config, otherwise the config will be ignored
vim.lsp.enable("lua_ls")
vim.lsp.enable("jsonls")
vim.lsp.enable("terraform_lsp")
vim.lsp.enable('efm')
vim.lsp.enable('ty')
vim.lsp.enable('ruff')
vim.lsp.enable('pylsp')
vim.lsp.enable("nil_ls")


-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>qq', vim.diagnostic.setloclist)

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ql', builtin.loclist, {})
vim.keymap.set('n', '<leader>qf', builtin.quickfix, {})
vim.keymap.set('n', '<leader>lr', builtin.lsp_references, {})

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
    vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<leader>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<leader>f', function()
      vim.lsp.buf.format { async = true }
    end, opts)


    -- Fast “Organize Imports” (Ruff)
    vim.keymap.set('n', '<leader>oi', function()
      vim.lsp.buf.code_action({
        apply = true,
        context = { only = { "source.organizeImports" }, diagnostics = {} },
      })
    end, { buffer = ev.buf, desc = "Organize imports (Ruff)" })

    -- Fast “Fix All” (Ruff)
    vim.keymap.set('n', '<leader>fa', function()
      vim.lsp.buf.code_action({
        apply = true,
        context = { only = { "source.fixAll" }, diagnostics = {} },
      })
    end, { buffer = ev.buf, desc = "Fix all (Ruff)" })

    -- Rope refactors: narrowed pickers on a VISUAL selection
    vim.keymap.set('x', '<leader>rv', function()
      vim.lsp.buf.code_action({
        context = { only = { "refactor.extract" }, diagnostics = {} },
      })
    end, { buffer = ev.buf, desc = "Refactor: extract (rope)" })

    vim.keymap.set('x', '<leader>ri', function()
      vim.lsp.buf.code_action({
        context = { only = { "refactor.inline" }, diagnostics = {} },
      })
    end, { buffer = ev.buf, desc = "Refactor: inline (rope)" })

    -- Rename stays direct (rope-backed via pylsp_rope)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename,
      { buffer = ev.buf, desc = "Rename symbol" })
  end,
})

vim.diagnostic.config({
  --virtual_text = { source = true }, -- show source next to virtual text (only if >1 source)
  float        = { source = true, border = "rounded" }, -- show source in hover float
})
