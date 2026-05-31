{ ... }: {
  home.file.".config/alacritty" = {
    source = ../config/alacritty;
    recursive = true;
  };
}
