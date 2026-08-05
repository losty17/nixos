{ pkgs, ... }:

{
  fonts.fontconfig.enable = true;

  home.packages = [
    pkgs.inter
    pkgs.nerd-fonts.symbols-only
  ];

  home.file.".config/quickshell/desktop-shell".source = ./desktop-shell;

  systemd.user.services.quickshell-desktop-shell = {
    Unit = {
      Description = "Quickshell desktop shell";
      After = [ "sway-session.target" ];
      PartOf = [ "sway-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.quickshell}/bin/quickshell --config desktop-shell";
      Restart = "on-failure";
      RestartSec = 2;
      Environment = [ "XDG_CONFIG_HOME=%h/.config" ];
    };

    Install = {
      WantedBy = [ "sway-session.target" ];
    };
  };
}
