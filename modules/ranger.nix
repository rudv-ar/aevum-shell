{ config, ... }: {
  home.file.".config/ranger".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/aevum/config/ranger";
}
