#!/bin/bash

AEVUM="$HOME/.config/aevum/config"
CONFIG="$HOME/.config"

dirs=(bspwm btop dunst fish geany kitty mpv neofetch nvim plank ranger rofi vicinae)

for d in "${dirs[@]}"; do
    src="$AEVUM/$d"
    dst="$CONFIG/$d"

    # Skip if source doesn't exist
    [[ ! -d "$src" ]] && echo "SKIP $d (not in aevum/config)" && continue

    # Remove existing (real dir, symlink, or broken symlink)
    if [[ -e "$dst" || -L "$dst" ]]; then
        rm -rf "$dst"
        echo "PURGED $dst"
    fi

    ln -s "$src" "$dst"
    echo "LINKED $d → $dst"
done


