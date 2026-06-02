{ pkgs, ... }:
let
  nordicTheme = {
    package = pkgs.nordic;
    name = "Nordic";
  };
in
{
  gtk = {
    enable = true;
    
    theme = nordicTheme;
    gtk4.theme = nordicTheme;

    iconTheme = {
      package = pkgs.nordzy-icon-theme;
      name = "Nordzy";
    };
  };
}

