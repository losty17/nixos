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
      push.autoSetupRemote = true;
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
    slack
    spotify
    tableplus
    bruno
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    GTK_IM_MODULE = "simple";
  };

  # User targeted configuration
  wayland.windowManager.sway = {
    config = {
      output = {
        "HDMI-A-1" = { position = "0,0"; };
        "eDP-1" = { position = "0,1080"; };
      };

      startup = [
        { command = "zen"; }
        { command = "slack"; }
        { command = "spotify"; }
      ];

      assigns = {
        "1" =  [{ app_id = "^Zen$"; }];
        "2" =  [{ app_id = "^Slack$"; }];
        "3" =  [{ app_id = "^Spotify$"; }];
      };

    };

    extraConfig = ''
      workspace 1 output HDMI-A-1
      workspace 2 output eDP-1
      workspace 3 output eDP-1
    '';
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
