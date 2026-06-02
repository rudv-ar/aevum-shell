{ config, ... }: {
  home.file.".config/matugen".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/aevum/config/matugen";
}
