{ ... }: {
  home.file.".config/rofi" = {
    source = ../config/rofi;
    recursive = true;
  };
}
