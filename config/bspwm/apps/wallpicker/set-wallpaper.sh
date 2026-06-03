#!/bin/bash

bsp_wall_dir="SHOME/.config/bspwm/bspwm.d/sources"
bsp_wall_source="$HOME/.config/bspwm/bspwm.d/sources/wallpaper.sh"
cur_wall=$(cat "$bsp_wall_source" | perl -ne 'if ( /\$wall_dir\/([^"]*)/) { print "$1" }')
mode="$(jq -r .mode ./config.json)"
wallname=$(basename "$1")
matugen image "$1" --type scheme-neutral --mode "$mode" --source-color-index 0 --json hex > ~/.config/aevum/shared/colors.json
feh --bg-fill "$1" && sed -i "s/$cur_wall/$wallname/g" "$bsp_wall_source"

