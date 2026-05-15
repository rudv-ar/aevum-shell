#!/bin/bash

BSPDIR="$HOME/.config/bspwm"
export PATH="${PATH}:$BSPDIR/src"

# ── Source all config atoms ───────────────────────────────────────────────────
# source "$BSPDIR/bspwm.d/sources/bspwm.sh"
source "$BSPDIR/bspwm.d/sources/services.sh"
source "$BSPDIR/bspwm.d/sources/wallpaper.sh"
source "$BSPDIR/bspwm.d/sources/widget.sh"
source "$BSPDIR/bspwm.d/sources/network.sh"

# ── Kill existing instances ───────────────────────────────────────────────────
killall -9 xsettingsd sxhkd dunst ksuperkey xfce4-power-manager \
            bspc polybar quickshell qs snapserver picom tor vicinae plank

# ── Polkit agent ──────────────────────────────────────────────────────────────
[[ ! $(pidof xfce-polkit) ]] && /usr/lib/xfce-polkit/xfce-polkit &

# ── Keybindings ───────────────────────────────────────────────────────────────
sxhkd -c "$BSPDIR/bspwm.d/sxhkdrc" &

# ── Super key ─────────────────────────────────────────────────────────────────
ksuperkey -e 'Super_L=Alt_L|F1' &
ksuperkey -e 'Super_R=Alt_L|F1' &

# ── Cursor ────────────────────────────────────────────────────────────────────
xsetroot -cursor_name left_ptr



# ── MPD ───────────────────────────────────────────────────────────────────────
[[ $is_svc_mpd == true ]] && systemctl --user start mpd &

# ── Wallpaper ─────────────────────────────────────────────────────────────────
if [[ $wall_single == true ]]; then
    feh --bg-fill "$wall_wallpaper"
elif [[ $wall_disfree == true ]]; then
    feh -z --no-fehbg --bg-fill "$wall_disfree_dir"
else
    feh -z --no-fehbg --bg-fill "$wall_dir"
fi

pkill kdeconnectd
if [[ $is_svc_kdeconnectd == true ]]; then
    kdeconnectd &
fi


# ── Vicinae ───────────────────────────────────────────────────────────────────
pkill vicinae
if [[ $is_svc_vicinae == true ]]; then
    vicinae server &
fi

# ── Dunst ─────────────────────────────────────────────────────────────────────
[[ $is_svc_dunst == true ]] && [[ $widget_bar != "quickshell" ]] && bspdunst &

# ── Bspfloat ──────────────────────────────────────────────────────────────────
bspfloat &




# ── Tor ───────────────────────────────────────────────────────────────────────
if [[ $is_net_tor == true ]]; then
    mkdir -p "$net_tor_torerrors"
    mkdir -p "$net_tor_torlogs"
    echo -e "\n\n=== TOR Started: $(date) ===\n\n" \
        >> "$net_tor_torlogs/log-$(date +%Y-%m-%d).log"
    tor -f "$net_tor_torrc" \
        2>> "$net_tor_torerrors/error-$(date +%Y-%m-%d).log" \
        1>> "$net_tor_torlogs/log-$(date +%Y-%m-%d).log" &
    notify-send "Tor" "Your internet is tunneled through Tor." -t 30000 -u normal
else
    notify-send "Tor" "Tor not enabled. You are on public network." -t 30000 -u normal
fi

# ── Snapserver ────────────────────────────────────────────────────────────────
if [[ $is_svc_snapserver == true ]]; then
    pactl load-module module-pipe-sink sink_name=snapfifo file=/tmp/snapfifo
    pactl set-default-sink snapfifo
    snapserver &
fi

# ── Widget bar ────────────────────────────────────────────────────────────────
[[ $is_widget == true ]] && bash "$BSPDIR/widgets/$widget_bar/launch.sh" &
[[ $is_plank == true ]] && plank &

sleep 2
# ── Picom ─────────────────────────────────────────────────────────────────────
if [[ $is_svc_picom == true ]]; then
    "$BSPDIR/bspwm.d/picomrc" &
else
    notify-send "Compositor" "Compositor not enabled. Shaders unavailable." -u normal -t 20000
fi

##---------------------------------------- Manager Scripts : All those use bspc subscribe to bring about some action----------------------------
bash "$BSPDIR/bspwm.d/exter_rules/raise_plank.sh" &

