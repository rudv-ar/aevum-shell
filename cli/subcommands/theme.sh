#!/usr/bin/env bash

# theme.sh - Modular theme switcher
# Usage: theme.sh switch mode <dark|light>

set -euo pipefail

CONFIG_JSON="$HOME/.config/bspwm/apps/wallpicker/config.json"
BSP_WALL_SOURCE="$HOME/.config/bspwm/bspwm.d/sources/wallpaper.sh"
COLORS_JSON="$HOME/.config/aevum/shared/colors.json"

# ── helpers ───────────────────────────────────────────────────────────────────

die()  { echo "theme.sh: error: $*" >&2; exit 1; }
info() { echo "theme.sh: $*"; }

get_current_wallpaper() {
    local raw_dir
    raw_dir=$(grep -oP '^wall_dir=\K.*' "$BSP_WALL_SOURCE" \
        | tr -d '"'"'" \
        | sed "s|\\\$HOME|$HOME|g; s|^~|$HOME|")

    [[ -n "$raw_dir" ]] || die "could not parse wall_dir from $BSP_WALL_SOURCE"

    local filename
    filename=$(perl -ne 'if (/\$wall_dir\/([^"'"'"'\s]+)/) { print "$1"; exit }' "$BSP_WALL_SOURCE")

    [[ -n "$filename" ]] || die "could not parse current wallpaper from $BSP_WALL_SOURCE"

    echo "$raw_dir/$filename"
}

# ── subcommands ───────────────────────────────────────────────────────────────

do_switch_mode() {
    local mode="$1"
    [[ "$mode" == "dark" || "$mode" == "light" ]] \
        || die "mode must be 'dark' or 'light', got: '$mode'"

    # 1. Patch config.json
    sed -i "s/\"mode\"\s*:\s*\"[^\"]*\"/\"mode\": \"$mode\"/" "$CONFIG_JSON"
    info "config.json → mode = $mode"

    # 2. Resolve current wallpaper
    local wall
    wall=$(get_current_wallpaper)
    [[ -f "$wall" ]] || die "wallpaper not found: $wall"
    info "wallpaper → $wall"

    # 3. Regenerate colors via matugen
    matugen image "$wall" \
        --type scheme-neutral \
        --mode "$mode" \
        --source-color-index 0 \
        --json hex > "$COLORS_JSON"

    info "matugen done → $COLORS_JSON"
}

# ── dispatcher ────────────────────────────────────────────────────────────────

case "${1:-}" in
    switch)
        case "${2:-}" in
            mode) do_switch_mode "${3:-}" ;;
            *)    die "unknown switch target '${2:-}'" ;;
        esac
        ;;
    *) die "usage: theme.sh switch mode <dark|light>" ;;
esac
