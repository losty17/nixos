{ config, pkgs, ... }:

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
    };
    extraConfig = builtins.readFile ./config;
  };

  home.packages = with pkgs; [
    swaylock
    swayidle
    wl-clipboard
  ];
}
