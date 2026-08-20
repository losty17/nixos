{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    ./common.nix
    ../modules/sway/sway.nix
    ../modules/quickshell/desktop-shell.nix
    ../modules/thunar/thunar.nix
    ../modules/zen-browser/zen-browser.nix
    ../modules/octapus-db/octapus-db.nix
    ../modules/nvim/nvim.nix
  ];

  # Use the NVIDIA-compatible wrapper installed by the NixOS Sway module.
  wayland.windowManager.sway.package = lib.mkForce null;

  programs.ghostty = {
    enable = true;
    settings = {
      window-padding-x = 8;
      window-padding-y = 8;
      background = "#0a0a0a";
      foreground = "#e6e8ee";
    };
  };

  home.packages = with pkgs; [
    vicinae
    spotify
    discord
    ani-cli
    prismlauncher
    ngrok
    live-server
    mosh

    # work related
    bruno
    posting
    opencode
    gemini-cli
    tableplus
    redisinsight
    (mongodb-compass.overrideAttrs (oldAttrs: {
      buildCommand = builtins.replaceStrings
        [ "wrapGAppsHook $out/bin/mongodb-compass" ]
        [ ":" ]
        oldAttrs.buildCommand;
      installPhase = oldAttrs.installPhase + ''
        wrapProgram $out/bin/mongodb-compass \
          --add-flags "--password-store=gnome-libsecret --ignore-additional-command-line-flags"
      '';
    }))
    (slack.overrideAttrs (oldAttrs: {
      installPhase = oldAttrs.installPhase + ''
        wrapProgram $out/bin/slack \
          --set NIXOS_OZONE_WL 0 \
          --add-flags "--ozone-platform=x11"
      '';
    }))
  ];

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSORS = "1"; # Fix for invisible cursor on NVIDIA Wayland
    GTK_IM_MODULE = "cedilla";
    QT_IM_MODULE = "cedilla";
  };

  home.file.".profile".text = ''
    export XDG_DATA_DIRS=$XDG_DATA_DIRS:/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share
  '';

  home.file."Pictures/Wallpapers".source = lib.mkForce (
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/nixos-config/hosts/desktop/wallpapers"
  );

  systemd.user.services.vicinae = {
    Unit = {
      Description = "Vicinae launcher daemon";
      After = [ "sway-session.target" ];
      PartOf = [ "sway-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.vicinae}/bin/vicinae server --replace";
      Restart = "on-failure";
      RestartSec = 2;
    };

    Install.WantedBy = [ "sway-session.target" ];
  };
}
