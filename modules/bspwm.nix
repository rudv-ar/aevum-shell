{ ... }: {
  home.file.".config/bspwm" = {
    source = ../config/bspwm;
    recursive = true;
  };
}
