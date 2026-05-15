#!/usr/bin/env bash

CONFIG="$1/config.json"

wallpaper_path=$(jq -r '.wallpaper_path' "$CONFIG")
cache_path=$(jq -r '.cache_path' "$CONFIG")
cache_batch_size=$(jq -r '.cache_batch_size' "$CONFIG")

RADIUS=16
mkdir -p "$cache_path"

process_image() {
    local img="$1"
    local filename
    filename=$(basename "$img")
    local out="$cache_path/${filename%.*}.png"

    [[ -f "$out" ]] && return

    echo "Generating thumbnail for $filename"

    local tmp="/tmp/_qs_$$_${filename}.miff"

    magick convert "$img" -thumbnail x500 -strip "$tmp" || return
    local w h
    w=$(identify -format "%w" "$tmp")
    h=$(identify -format "%h" "$tmp")

    magick convert "$tmp" \
        -alpha set \
        \( -size ${w}x${h} xc:none \
           -fill white \
           -draw "roundRectangle 0,0 $((w-1)),$((h-1)) ${RADIUS},${RADIUS}" \
        \) \
        -compose DstIn -composite \
        "$out"

    rm -f "$tmp"
}

export -f process_image
export cache_path RADIUS

find "$wallpaper_path" -type f \( \
    -iname "*.jpg" -o \
    -iname "*.jpeg" -o \
    -iname "*.png" \
\) | xargs -P "${cache_batch_size:-4}" -I{} bash -c 'process_image "$@"' _ {}

echo "Thumbnail generation complete."
