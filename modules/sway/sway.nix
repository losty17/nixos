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

      keybindings = let
        mod = config.wayland.windowManager.sway.config.modifier;
      in lib.mkOptionDefault {
        "${mod}+d" = "exec noctalia-shell ipc call launcher toggle";    
        "${mod}+Return" = "exec ${config.wayland.windowManager.sway.config.terminal}";
        "${mod}+Shift+q" = "kill";
        "${mod}+Shift+4" = "exec grim -g \"$(slurp)\" - | wl-copy";
        "XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +5%";
        "XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -5%";
        "XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
        "XF86MonBrightnessUp" = "exec brightnessctl set +10%";
        "XF86MonBrightnessDown" = "exec brightnessctl set 10%-";
      };
    };

    extraConfig = builtins.readFile ./config;
  };

  home.packages = with pkgs; [
    grim
    slurp
    swaylock
    swayidle
    wl-clipboard
  ];
}
