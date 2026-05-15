#!/bin/bash

PTH="$HOME/.config/bspwm/bspwm.d"
source "$PTH/exports.sh"

########## BORDERS ##########
IS_BSPWM_BORDERS=true
BSPWM_BORDERS_STYLE='solid'
if [[ $IS_BSPWM_BORDERS == true ]]; then
    BSPWM_BORDERS_FOCUSED_COLOR='#414868'
    BSPWM_BORDERS_NORMAL_COLOR='#1e1e2e'
    BSPWM_BORDERS_ACTIVE_COLOR='#000000'
    BSPWM_BORDERS_WIDTH=2
else
    BSPWM_BORDERS_WIDTH=0
fi

########## PRESEL ##########
IS_BSPWM_PRESEL=true
if [[ $IS_BSPWM_PRESEL == true ]]; then
    BSPWM_PRESEL_PFC='#6272a4'
else
    BSPWM_PRESEL_PFC='#000000'
fi

########## WINDOW ##########
BSPWM_WINDOW_SR_RATIO=0.5
BSPWM_WINDOW_PREFIX=''
#----------------- gapped -----------------#
IS_BSPWM_WINDOW_GAPPED=true
if [[ $IS_BSPWM_WINDOW_GAPPED == true ]]; then
    BSPWM_WINDOW_GAPPED_GAP=10
else
    BSPWM_WINDOW_GAPPED_GAP=0
fi
#----------------- padded -----------------#
IS_BSPWM_WINDOW_PADDED=false
if [[ $IS_BSPWM_WINDOW_PADDED == true ]]; then
    BSPWM_WINDOW_PADDED_TOP=10
    BSPWM_WINDOW_PADDED_BOTTOM=10
    BSPWM_WINDOW_PADDED_LEFT=10
    BSPWM_WINDOW_PADDED_RIGHT=10
else
    BSPWM_WINDOW_PADDED_TOP=0
    BSPWM_WINDOW_PADDED_BOTTOM=0
    BSPWM_WINDOW_PADDED_LEFT=0
    BSPWM_WINDOW_PADDED_RIGHT=0
fi

########## SCHEME ##########
#----------------- automatic -----------------#
IS_BSPWM_SCHEME_AUTOMATIC=true
if [[ $IS_BSPWM_SCHEME_AUTOMATIC == true ]]; then
    BSPWM_SCHEME_AUTOMATIC_SCHEME='spiral'
    BSPWM_SCHEME_AUTOMATIC_INITIAL_POLARITY='second_child'
else
    BSPWM_SCHEME_AUTOMATIC_SCHEME='monocle'
    BSPWM_SCHEME_AUTOMATIC_INITIAL_POLARITY='first_child'
fi

########## MONOCLE ##########
IS_BSPWM_MONOCLE_BORDERLESS=true
IS_BSPWM_MONOCLE_GAPLESS=true
IS_BSPWM_MONOCLE_SINGLE=false

########## WALLPAPER ##########
BSPWM_WALLPAPER_WALLPAPER="$HOME/.config/bspwm/walls.ref/080.png"
BSPWM_WALLPAPER_DIR="$HOME/.config/bspwm/walls/"
BSPWM_WALLPAPER_DISFREE_DIR="$HOME/.config/bspwm/walls/disfree/"
BSPWM_WALLPAPER_DISFREE=false
BSPWM_WALLPAPER_SINGLE=true

########## WIDGET ##########
IS_BSPWM_WIDGET=true
BSPWM_WIDGET_BAR='quickshell'

########## SERVICES ##########
#----------------- picom -----------------#
IS_BSPWM_SERVICES_PICOM=true
#----------------- snapserver -----------------#
IS_BSPWM_SERVICES_SNAPSERVER=true
#----------------- vicinae -----------------#
IS_BSPWM_SERVICES_VICINAE=true
#----------------- dunst -----------------#
IS_BSPWM_SERVICES_DUNST=true
#----------------- mpd -----------------#
IS_BSPWM_SERVICES_MPD=true

########## NETWORK ##########
IS_BSPWM_NETWORK=true
BSPWM_NETWORK_TIMEOUT=30
BSPWM_NETWORK_RETRY=3
#----------------- wifi -----------------#
IS_BSPWM_NETWORK_WIFI=true
BSPWM_NETWORK_WIFI_DRIVER='iwlwifi'
if [[ $IS_BSPWM_NETWORK_WIFI == true ]]; then
    BSPWM_NETWORK_WIFI_INTERFACE_1='wlan0'
    BSPWM_NETWORK_WIFI_INTERFACE_2='wlan1'
else
    BSPWM_NETWORK_WIFI_INTERFACE='wlan2'
fi
#----------------- tor -----------------#
IS_BSPWM_NETWORK_TOR=false
BSPWM_NETWORK_TOR_PROXY_PORT=9050
if [[ $IS_BSPWM_NETWORK_TOR == true ]]; then
    BSPWM_NETWORK_TOR_TORINSTANCE="$HOME/.config/bspwm/apps/tor-instance"
    BSPWM_NETWORK_TOR_TORRC="$HOME/.config/bspwm/apps/tor-instance/torrc"
    BSPWM_NETWORK_TOR_TORLOGS="$HOME/.config/bspwm/apps/tor-instance/logs"
    BSPWM_NETWORK_TOR_TORERRORS="$HOME/.config/bspwm/apps/tor-instance/errors/"
else
    BSPWM_NETWORK_TOR_TORRC='/etc/tor/torrc'
fi
#----------------- ethernet -----------------#
IS_BSPWM_NETWORK_ETHERNET=true
BSPWM_NETWORK_ETHERNET_MAC='aa:bb:cc:dd:ee:ff'
if [[ $IS_BSPWM_NETWORK_ETHERNET == true ]]; then
    BSPWM_NETWORK_ETHERNET_INTERFACE='eth0'
fi
#----------------- firewall -----------------#
IS_BSPWM_NETWORK_FIREWALL=true
BSPWM_NETWORK_FIREWALL_BACKEND='nftables'
BSPWM_NETWORK_FIREWALL_LOG_LEVEL='warn'
if [[ $IS_BSPWM_NETWORK_FIREWALL == true ]]; then
    BSPWM_NETWORK_FIREWALL_RULES='/etc/firewall.rules'
fi

