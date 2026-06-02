{ config, ... }: {
  home.file.".config/bspwm".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/aevum/config/bspwm";
}
