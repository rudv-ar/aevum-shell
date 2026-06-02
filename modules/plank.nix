{ config, ... }: {
  home.file.".config/plank".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/aevum/config/plank";
}
