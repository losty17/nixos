{ config, pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    clock24 = true;

    plugins = with pkgs; [
      {
        plugin = tmuxPlugins.catppuccin;
      }
      {
        plugin = tmuxPlugins.sensible;
      }
      {
        plugin = tmuxPlugins.continuum;
      }
      {
        plugin = tmuxPlugins.resurrect;
        extraConfig = ''
          resurrect_dir="$HOME/.tmux/resurrect"
          set -g @resurrect-dir $resurrect_dir
          set -g @resurrect-hook-post-save-all 'target=$(readlink -f $resurrect_dir/last); sed "s| --cmd.*-vim-pack-dir||g; s|/etc/profiles/per-user/$USER/bin/||g; s|/home/$USER/.nix-profile/bin/||g" $target | sponge $target'
          set -g @resurrect-capture-pane-contents 'on'
          set -g @resurrect-strategy-vim 'session'
        '';
      }
    ];

    extraConfig = builtins.readFile ./tmux.conf;
  };
}
