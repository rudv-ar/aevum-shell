#!/bin/bash

#set -Eeuo pipefail
#trap 'echo "[ERROR] line $LINENO: $BASH_COMMAND" >&2' ERR
############################## VARIABLES ####################################
# define the prefix path
# see in current directory

PTH="$HOME/.config/bspwm/bspwm.d"
SOURCEPTH="$PTH/sources"
############################### SOURCE ######################################

source "$SOURCEPTH/bspwm.sh"


############################## FUNCTIONS ####################################

source "$HOME/.config/bspwm/bspwm.d/wm.sh"

# ── Borders ───────────────────────────────────────────────────────────────────

configure_border() {
    if [[ $is_bspwm_borders == true ]]; then
        bspc config border_width         "$bspwm_borders_width"
        bspc config focused_border_color "$bspwm_borders_focused_color"
        bspc config normal_border_color  "$bspwm_borders_normal_color"
        bspc config active_border_color  "$bspwm_borders_active_color"
    else
        bspc config border_width 0
    fi
}

# ── Windows ───────────────────────────────────────────────────────────────────

configure_windows() {
    bspc config split_ratio    "$bspwm_window_sr_ratio"
    bspc config window_gap     "$bspwm_window_gapped_gap"
    bspc config top_padding    "$bspwm_window_padded_top"
    bspc config bottom_padding "$bspwm_window_padded_bottom"
    bspc config left_padding   "$bspwm_window_padded_left"
    bspc config right_padding  "$bspwm_window_padded_right"
    
    if [[ $is_bspwm_presel == true ]]; then
        bspc config presel_feedback       true
        bspc config presel_feedback_color "$bspwm_presel_pfc"
    else
        bspc config presel_feedback false
    fi
}

# ── Scheme ────────────────────────────────────────────────────────────────────

configure_scheme() {
    if [[ $is_bspwm_scheme_automatic == true ]]; then
        bspc config automatic_scheme "$bspwm_scheme_automatic_scheme"
        bspc config initial_polarity "$bspwm_scheme_automatic_initial_polarity"
    fi
}

# ── Monocle ───────────────────────────────────────────────────────────────────

configure_monocle() {
    bspc config borderless_monocle "$bspwm_monocle_borderless"
    bspc config gapless_monocle    "$bspwm_monocle_gapless"
    bspc config single_monocle     "$bspwm_monocle_single"
}

configure_prefix() {
    bspc config status_prefix  "$bspwm_window_prefix"
}
# ── Dispatch ──────────────────────────────────────────────────────────────────

bspc_configure() {
    case ${1} in
        border)  configure_border  ;;
        windows) configure_windows ;;
        scheme)  configure_scheme  ;;
        monocle) configure_monocle ;;
        status_prefix) configure_prefix   ;;
    esac
}

# ── Run ───────────────────────────────────────────────────────────────────────


############################# COMMAND #######################################
# By default, configure everything, make it modular and extensible
# Add focus essentials
bspc config focus_follows_pointer "true"
#bspc_configure border 
#bspc_configure windows 
#bspc_configure scheme 
#bspc_configure status_prefix
#bspc_configure monocle 
#check_source
### Want minimal?
### Just configure border and windows. enough...
