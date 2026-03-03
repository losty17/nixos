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
    settings = {
      # configure noctalia here
      bar = {
        density = "default";
        position = "top";
        showCapsule = false;
        widgets = {
          left = [
            {
              id = "ControlCenter";
              # useDistroLogo = true;
            }
          ];
          center = [
            {
              hideUnoccupied = false;
              id = "Workspace";
              labelMode = "none";
            }
          ];
          right = [
            {
              alwaysShowPercentage = false;
              id = "Battery";
              warningThreshold = 30;
            }
            {
              id = "Bluetooth";
            }
            {
              id = "Network";
            }
            {
              formatHorizontal = "HH:mm";
              formatVertical = "HH mm";
              id = "Clock";
              useMonospacedFont = true;
              usePrimaryColor = true;
            }
          ];
        };
      };
      colorSchemes.predefinedScheme = "Monochrome";
      general = {
        avatarImage = "/home/drfoobar/.face";
        radiusRatio = 0.2;
        enableShadows = false;
      };
      location = {
        monthBeforeDay = true;
        name = "Santa Cruz do Sul, Rio Grande do Sul, Brasil";
      };
    };
    # this may also be a string or a path to a JSON file.
  };
}
