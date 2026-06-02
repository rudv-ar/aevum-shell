{ pkgs, ... }:
{
  gtk = {
    enable = true;
    
    theme = {
      package = pkgs.nordic;
      name = "Nordic";
    };

    iconTheme = {
      package = pkgs.nordzy-icon-theme;
      name = "Nordzy";
    };

    gtk4.theme = config.gtk.theme;
    
  };
}

