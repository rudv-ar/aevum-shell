{ config, ... }: {
  home.file.".config/btop".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/aevum/config/btop";
}
