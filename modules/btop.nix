{ ... }: {
  home.file.".config/btop" = {
    source = ../config/btop;
    recursive = true;
  };
}
