{ config, pkgs, lib, ... }:

{
  wayland.windowManager.sway = {
    enable = true;
    config = rec {
      modifier = "Mod4";
      terminal = "ghostty";
      
      # defaultBorder = "pixel 1";
      # defaultFloatingBorder = "pixel 1";
      # hideEdgeBorders = "smart";

      startup = [
        { command = "noctalia-shell"; }
      ];

      bars = [];

      # keybindings = let
      #   mod = config.wayland.windowManager.sway.config.modifier;
      # in {
      #   # Terminal
      #   "${mod}+return" = "GTK_IM_MODULE=simple exec ghostty";    
      # };
    };

    extraConfig = builtins.readFile ./config;
  };

  home.packages = with pkgs; [
    swaylock
    swayidle
    wl-clipboard
  ];
}
