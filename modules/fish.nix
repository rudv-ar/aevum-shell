{ config, ... }: {
  home.file.".config/fish".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/aevum/config/fish";
}
