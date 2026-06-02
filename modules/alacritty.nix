{ config, ... }: {
  home.file.".config/alacritty".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/aevum/config/alacritty";
}
