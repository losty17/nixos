{ inputs, pkgs, ... }:

{
  home.packages = [
    inputs.octapus-db.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
