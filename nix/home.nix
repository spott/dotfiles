{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "spott";
  home.homeDirectory = "/Users/spott";

  #nixpkgs.config = import ./nixpkgs-config.nix;
  #xdg.configFile."nixpkgs/config.nix".source = ./nixpkgs-config.nix;

  xdg.configFile."git/config".source = ./git/config;

  nix.package = pkgs.nix;
  nix.settings = { experimental-features = [ "nix-command" "flakes" ]; };

  # Packages:
  home.packages = with pkgs; [
    delta
    bottom
    du-dust
    fd
    ripgrep
    duf
    dog
    lsd
  ];

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
  # zsh
  #
  programs.zsh.enable = true;
  programs.zsh.dotDir = ".config/zsh";
  programs.zsh.initExtraFirst = "source \"${config.home.homeDirectory}/.config/zsh/.zshrc_personal\"";
  programs.zsh.history.path = "\$ZDOTDIR/.zsh_history";
  programs.zsh.dirHashes = {
    nix   = "$HOME/.dotfiles/nix";
    proj  = "$HOME/projects";
    ic    = "$HOME/iCloudDocuments";
    docs  = "$HOME/Documents";
  };
  programs.zsh.shellAliases = {
    cat = "bat";
    diff = "delta";
    df = "duf";
    du = "dust";
    dog = "dig";
    find = "fd";
    top = "btm";
    grep = "rg";
    vim = "nvim";
  };
  
  # 
  # SSH
  #
  programs.ssh.enable = true;
  programs.ssh.extraConfig = "IdentityAgent \"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\"";
  
  #
  # vscode:
  # 
  # programs.vscode.enable
  
  #
  # gh (github commandline)
  # 
  programs.gh.enable = true;
  programs.gh.settings.git_protocol = "ssh";


}
