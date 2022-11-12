{config, pkgs, ...}:
{
  nixpkgs.config = import ./nixpkgs-config.nix;
  xdg.configFile."nixpkgs/config.nix".source = ./nixpkgs-config.nix;

  xdg.configFile."git/config".source = ./git/config;

  nix.package = pkgs.nix;
  nix.settings = { experimental-features = [ "nix-command" "flakes" ]; 
                   extra-platforms = [ "x86_64_darwin" "aarch64_darwin" ]; };


  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  #
  # bat (cat replacement)
  #
  programs.bat.enable = true;
  programs.bat.config = {
    theme = "Dracula";
  };


  #
  # bottom (btm command, top replacement)
  #
  programs.bottom.enable = true;
  # see https://github.com/ClementTsang/bottom/blob/master/sample_configs/default_config.toml for possiblities
  #programs.bottom.settings

  #
  # direnv
  #
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.direnv.enableZshIntegration = true;

  #
  # exa (ls replacement)
  #
  programs.exa.enable = true;

  # 
  # tmux
  #
  programs.tmux.enable = true;
  programs.tmux.keyMode= "vi";
  programs.tmux.prefix = "C-a";

  #
  # neovim
  #
  programs.neovim.enable = true;
  xdg.configFile."nvim/init.lua".source = ./nvim/init.lua;
  xdg.configFile."nvim/lua/bootstrap.lua".source = ./nvim/lua/bootstrap.lua;

  # 
  # SSH
  #
  programs.ssh.enable = true;
  programs.ssh.extraConfig = "IdentityAgent \"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\"";

  #
  # vscode:
  # 
  #programs.vscode.enable = true;

  #
  # fzf
  #
  programs.fzf.enable = true;

  #
  # aria2
  #
  programs.aria2.enable = true;
  
  #
  # gh (github commandline)
  # 
  programs.gh.enable = true;
  programs.gh.settings.git_protocol = "ssh";

  # 
  # Kitty
  #
  programs.kitty.enable = true;
  programs.kitty.font.name = "Hurmit Nerd Font";
  programs.kitty.font.size = "12";
  programs.kitty.settings = {
    scrollback_lines = 100000;
    enable_audio_bell = false;
    update_check_interval = 0.0;
    scrollback_pager = "less --chop-long-lines --RAW-CONTROL-CHARS +INPUT_LINE_NUMBER";
    scrollback_pager_history_size = 100;
    };
  programs.kitty.theme = "Dracula"
}
