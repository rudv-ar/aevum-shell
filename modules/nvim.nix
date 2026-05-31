{ ... }: {
  home.file.".config/nvim" = {
    source = ../config/nvim;
    recursive = true;
  };
}
