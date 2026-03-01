# /etc/nixos/configuration.nix

{ config, inputs, pkgs, ... }:

let
  swayConfig = pkgs.writeText "greetd-sway-config" ''
    # `-l` activates layer-shell mode. Notice that `swaymsg exit` will run after gtkgreet.
    exec "${pkgs.greetd.gtkgreet}/bin/gtkgreet -l; swaymsg exit"
    bindsym Mod4+shift+e exec swaynag \
      -t warning \
      -m 'What do you want to do?' \
      -b 'Poweroff' 'systemctl poweroff' \
      -b 'Reboot' 'systemctl reboot'
  '';
in
{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.sway}/bin/sway --config ${swayConfig}";
      };
    };
  };

  imports =
    [ 
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.default
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.hostName = "kappke"; # Define your hostname.
  networking.networkmanager.enable = true;

  hardware.bluetooth.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "br";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "br-abnt2";

  security.polkit.enable = true;
  programs.light.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kappke = {
    isNormalUser = true;
    description = "Vinícius Kappke";
    extraGroups = [ "networkmanager" "wheel" "video" ];
    packages = with pkgs; [];
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "kappke" = import ../../users/kappke.nix;
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim
  ];

  system.stateVersion = "25.11"; # Did you read the comment?


}
