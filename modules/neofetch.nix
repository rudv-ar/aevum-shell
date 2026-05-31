{ ... }: {
  home.file.".config/neofetch" = {
    source = ../config/neofetch;
    recursive = true;
  };
}
