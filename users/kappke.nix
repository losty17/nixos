{ config, pkgs, ... }:

{
  home.username = "kappke";
  home.homeDirectory = "/home/kappke";

  home.stateVersion = "25.11"; 

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Vinícius Kappke";
        email = "vinikappke@gmail.com";
        signingkey = "~/.ssh/id_ed25519.pub";
      };

      alias = {
        
      };

      gpg = {
        format = "ssh";
        ssh.allowedSignersFile = "~/.ssh/allowed_signers";
      };

      commit.gpgsign = true;
      init.defaultBranch = "master";
    };
  };

  imports = [
    ../modules/zsh/zsh.nix
    ../modules/sway/sway.nix
    ../modules/nvim/nvim.nix
    ../modules/tmux/tmux.nix
    ../modules/thunar/thunar.nix
    ../modules/noctalia/noctalia.nix
    ../modules/zen-browser/zen-browser.nix
  ];

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    ghostty
    slack
    spotify
    pyenv
    bun
    nodejs
    fzf
    ripgrep
    gcc
    cmake
    gnumake
    go
    fastfetch
    tree
    tree-sitter # nvim utility
    prettierd # general formatter 
    black # python formatter
    tableplus
    figma-linux
    luajitPackages.luarocks_bootstrap
    grim
    slurp
    wget
    zip
    unzip
    python3
    lua
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    GTK_IM_MODULE = "simple";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
