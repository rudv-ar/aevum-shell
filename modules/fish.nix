{ ... }:
{
  home.file.".config/fish" = {
    source = ../config/fish;
    recursive = true;
  };
}
