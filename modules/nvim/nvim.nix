{ config, pkgs, ... }:
{
  # home.packages = {
  #   fzf
  #   ripgrep
  # };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };
}
