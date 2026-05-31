{ pkgs, ... }:
{
  home = {
    username = "cobra";
    homeDirectory = "/home/cobra";
    stateVersion = "24.11";
    packages = with pkgs; [
      git 
    ];
  };

  targets.genericLinux.enable = true;

  imports = [
    ./modules/alacritty.nix
    ./modules/fish.nix
    ./modules/btop.nix 
    ./modules/dunst.nix 
    ./modules/bspwm.nix 
    ./modules/geany.nix 
    ./modules/matugen.nix 
    ./modules/neofetch.nix 
    ./modules/nvim.nix 
    ./modules/plank.nix 
    ./modules/ranger.nix 
    ./modules/rofi.nix 
    ./modules/vicinae.nix
    ./modules/git.nix
  ];
}
