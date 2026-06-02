#!/bin/bash

# file : wallpaper.sh 
# function : sourced by autostart.sh to apply the wallpapers

############################################## WALLPAPERS #########################################

# default wallpaper dir, where random wallpapers are picked from
wall_dir="$HOME/Pictures/Wallpapers"

# is the wallpaper distraction free? like not silly animae sulk? not colour stuffs? just pure black, mission mode?
wall_disfree=false

# where to find those disfree wallpapers?
wall_disfree_dir="$HOME/Pictures/Wallpapers"

# instead of random wallpaper apply only a single wallpaper?
wall_single=true

# the path of that single wallpaper
wall_wallpaper="$wall_dir/ign_batman.png"
