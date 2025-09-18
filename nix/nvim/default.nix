{pkgs, ...}:
#
# neovim
#
# pylsp env
let
  pylspEnv = pkgs.python312.withPackages (ps: [
    ps.python-lsp-server
    ps.pylsp-rope
    ps.rope
  ]);

  dapPy = pkgs.unstable.python312.withPackages (ps: [ ps.debugpy ps.pytest ]);
in {

  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;
  programs.neovim.withNodeJs = true;
  programs.neovim.withPython3 = true;
  programs.neovim.viAlias = true;
  programs.neovim.vimAlias = true;
  programs.neovim.vimdiffAlias = true;
  programs.neovim.extraPackages = with pkgs; [
    tree-sitter
    vscode-langservers-extracted
    terraform-lsp
    efm-langserver
    unstable.basedpyright
    lua-language-server
    alejandra
    nil
    unstable.ruff
    fzf
    ripgrep
    unstable.ty
    python312Packages.rope
    python312Packages.debugpy
    uv
    pylspEnv
  ];

  home.sessionVariables = {
    PYLSP_BIN = "${pylspEnv}/bin/pylsp";
    DAP_PYTHON = "${dapPy}/bin/debugpy-adapter";
  };

  programs.neovim.plugins = with pkgs.unstable.vimPlugins; [
    # actions
    nvim-surround
    comment-nvim
    vim-ReplaceWithRegister

    # treesitter
    nvim-treesitter.withAllGrammars
    nvim-treesitter-textobjects
    nvim-ts-context-commentstring

    # telescope (fuzzy finder)
    telescope-fzf-native-nvim
    telescope-nvim

    # completion
    cmp-async-path
    nvim-cmp

    # common dependencies
    plenary-nvim

    # formatting
    efmls-configs-nvim

    # icons
    nvim-web-devicons

    # statusline
    lualine-nvim

    # git
    neogit
    diffview-nvim

    # LSP
    cmp-nvim-lsp
    nvim-lspconfig

    # file manager
    triptych-nvim

    # lsp file operations
    nvim-lsp-file-operations

    # debugging
    nvim-dap
    nvim-dap-python
    nvim-dap-ui
    nvim-dap-virtual-text

    # Testing
    neotest
    neotest-python
    nvim-nio

    # AI
    codecompanion-nvim
    supermaven-nvim
    copilot-lua

    (pkgs.vimUtils.buildVimPlugin
      {
        pname = "flexoki-nvim";
        version = "079554c242a86be5d1a95598c7c6368d6eedd7a3";
        src = pkgs.fetchFromGitHub {
          owner = "nuvic";
          repo = "flexoki-nvim";
          rev = "079554c242a86be5d1a95598c7c6368d6eedd7a3";
          sha256 = "vjjAulQVFS+OmpWzLkliqpan3GXlvatdaCnI96bjxC0=";
        };
      })
  ];

  xdg.configFile."nvim/init.lua".source = ./init.lua;
  xdg.configFile."nvim/lua/lsp.lua".source = ./lua/lsp.lua;
  xdg.configFile."nvim/lua/ai.lua".source = ./lua/ai.lua;

  xdg.configFile."nvim/lua/dap_config.lua".source = ./lua/dap_config.lua;
  xdg.configFile."nvim/lua/tests.lua".source = ./lua/tests.lua;
}
