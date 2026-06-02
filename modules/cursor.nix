{ pkgs, ... }:
{
  home.pointerCursor = {
    package = pkgs.nordzy-cursor-theme;
    name = "Nordzy-cursors";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };
}

