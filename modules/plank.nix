{ ... }: {
  home.file.".config/plank" = {
    source = ../config/plank;
    recursive = true;
  };
}
