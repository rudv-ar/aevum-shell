{ ... }: {
  home.file.".config/ranger" = {
    source = ../config/ranger;
    recursive = true;
  };
}
