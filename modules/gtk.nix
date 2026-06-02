{ pkgs, ... }:
{
  
  gtk = {
    enable = true;
    
    theme = {
      package = pkgs.nordic;
      name = "Nordic";
    };

    gtk4.theme = theme;
    iconTheme = {
      package = pkgs.nordzy-icon-theme;
      name = "Nordzy";
    };

    
  };
}

