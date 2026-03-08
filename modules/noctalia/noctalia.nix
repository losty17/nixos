{ pkgs, inputs, ... }:
{
  # import the home manager module
  imports = [
    inputs.noctalia.homeModules.default
  ];

  home.packages = with pkgs; [
    quickshell
  ];

  # configure options
  programs.noctalia-shell = {
    enable = true;
  };
}
