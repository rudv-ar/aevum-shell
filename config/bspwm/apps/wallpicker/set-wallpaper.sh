#!/bin/bash

bsp_wall_dir="$HOME/.config/bspwm/bspwm.d/sources"
bsp_wall_source="$HOME/.config/bspwm/bspwm.d/sources/wallpaper.sh"
cur_wall=$(cat "$bsp_wall_source" | perl -ne 'if ( /\$wall_dir\/([^"]*)/) { print "$1" }')
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mode_wall="$(jq -r .mode "$script_dir/config.json")"
echo "$mode_wall"
wallname=$(basename "$1")
matugen image "$1" --type scheme-neutral --mode "$mode_wall" --source-color-index 0 --json hex > ~/.config/aevum/shared/colors.json
feh --bg-fill "$1" && sed -i "s/$cur_wall/$wallname/g" "$bsp_wall_source"

