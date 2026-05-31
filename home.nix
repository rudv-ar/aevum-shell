{ pkgs, ... }:
{
  home = {
    username = "cobra";
    homeDirectory = "/home/cobra";
    stateVersion = "24.11";
    packages = with pkgs; [];
  };

  targets.genericLinux.enable = true;

  imports = [
    ./modules/alacritty.nix
    ./modules/fish.nix
  ];
}
