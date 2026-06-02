{ pkgs, lib, ... }:
{
  home = {
    username = "cobra";
    homeDirectory = "/home/cobra";
    stateVersion = "24.11";
    packages = with pkgs; [
      git 
      openssh

      # install the xsetroot. but I have it pacman installed, so do you | uncomment if needed.
      # xorg.xsetroot
    ];

    activation.reloadBspwm = lib.hm.dag.entryAfter ["writeBoundary"] ''
      /usr/bin/bspc wm -r;
    '';    
  };

  targets.genericLinux.enable = true;

  imports = [
    ./modules/xdg.nix 
    ./modules/cursor.nix
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
    ./modules/mpd.nix 
  ];
}
