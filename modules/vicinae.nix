{ ... }: {
  home.file.".config/vicinae" = {
    source = ../config/vicinae;
    recursive = true;
  };
}
