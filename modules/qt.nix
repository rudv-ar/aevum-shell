# modules/qt.nix
{ pkgs, ... }:
{
  # Point Qt apps at Kvantum via qt5ct/qt6ct
  qt = {
    enable = true;
    platformTheme.name = "qtct"; # sets QT_QPA_PLATFORMTHEME=qt5ct/qt6ct
    style = {
      name = "kvantum";
      package = pkgs.kdePackages.qtstyleplugin-kvantum; # Qt6 Kvantum
    };
  };

  # Symlink Nordic-Darker Kvantum theme from pkgs.nordic into ~/.config/Kvantum/
  # (Kvantum won't scan the Nix store on non-NixOS, so we link manually)
  xdg.configFile = {
    "Kvantum/Nordic-Darker".source = "${pkgs.nordic}/share/Kvantum/Nordic-Darker";
    "Kvantum/kvantum.kvconfig".text = ''
      [General]
      theme=Nordic-Darker
    '';
  };

  home.packages = with pkgs; [
    libsForQt5.qtstyleplugin-kvantum # Qt5 Kvantum (covers legacy Qt5 apps)
    qt5ct
    qt6ct
  ];
}
