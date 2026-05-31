{ pkgs, ... }:
{
  home = {
    username = "cobra";
    homeDirectory = "/home/cobra";
    stateVersion = "24.11";
    packages = with pkgs; [
      zoxide 
      eza 
      figlet 
      starship 
      alacritty
    ];
  };

  targets.genericLinux.enable = true;

  imports = [
    ./modules/alacritty.nix
    ./modules/fish.nix
  ];
}
