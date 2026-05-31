{ ... }: {
  home.file.".config/matugen" = {
    source = ../config/matugen;
    recursive = true;
  };
}
