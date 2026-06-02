{ config, ... }: {
  home.file.".config/neofetch".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/aevum/config/neofetch";
}
