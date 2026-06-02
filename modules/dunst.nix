{ config, ... }: {
  home.file.".config/dunst".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/aevum/config/dunst";
}
