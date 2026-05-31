{ pkgs, ...}: {
  home.username = "cobra";
  home.homeDirectory = "/home/cobra";
  home.stateVersion = "24.11";
  targets.genericLinux.enable = true;
  home.packages = with pkgs; [];
}
