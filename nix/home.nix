{ config, pkgs, ... }:
{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "spott";
  home.homeDirectory = "/Users/spott";

  nixpkgs.config = import ./nixpkgs-config.nix;
  xdg.configFile."nixpkgs/config.nix".source = ./nixpkgs-config.nix;

  xdg.configFile."git/config".source = ./git/config;

  nix.package = pkgs.nix;
  nix.settings = { experimental-features = [ "nix-command" "flakes" ]; 
                   extra-platforms = [ "x86_64_darwin" "aarch64_darwin" ]; };
	
 # inherit zsh;
  # Packages:
  home.packages = with pkgs; [
  # shell
    delta # diff pager
    difftastic # diff engine
    bottom # top replacement
    du-dust # du replacement
    fd # find replacement
    ripgrep # grep replacement
    duf # df replacement
    dogdns # dig replacement
    lsd # ls replacement... I'm using exa, so this might not be necessary
    sd # sed replacement
    tldr # examples for commands
    mosh # ssh replacement

  # iac (only needed on Normandy... but might as well install them everywhere
    terraform
    ansible
    pulumi-bin
    kubectl

  # development
    #python310Packages.poetry
    (poetry.override {python = python310;})
    python39Full
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
  # SSH
  #
  programs.ssh.enable = true;
  programs.ssh.extraConfig = "IdentityAgent \"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\"";
  
  #
  # vscode:
  # 
  #programs.vscode.enable = true;
  
  #
  # gh (github commandline)
  # 
  programs.gh.enable = true;
  programs.gh.settings.git_protocol = "ssh";


}
