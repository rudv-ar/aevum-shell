{ ... }: {
  home.file.".config/geany" = {
    source = ../config/geany;
    recursive = true;
  };
}
