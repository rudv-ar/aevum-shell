{ config, ... }: {
  home.file.".config/geany".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/aevum/config/geany";
}
