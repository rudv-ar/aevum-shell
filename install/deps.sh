#!/bin/bash 
# ~/.config/aevum/deps.sh

# ── Archcraft Repo ────────────────────────────────────────────────────────────
if grep -q "\[archcraft\]" /etc/pacman.conf; then
    echo ":: Archcraft repo already present, skipping"
else
    echo ":: Writing Archcraft mirrorlist..."
    sudo tee /etc/pacman.d/archcraft-mirrorlist > /dev/null <<'EOF'
############### Archcraft Mirrorlist ###############

## Worldwide (Github)
Server = https://packages.archcraft.io/$arch
EOF

    echo ":: Adding Archcraft repo to pacman.conf..."
    sudo tee -a /etc/pacman.conf > /dev/null <<'EOF'

[archcraft]
SigLevel = Optional TrustAll
Include = /etc/pacman.d/archcraft-mirrorlist
EOF
    echo ":: Making a complete upgrade - Syu..."
    sudo pacman -Syu
fi

# ── Pacman Deps ───────────────────────────────────────────────────────────────
PACMAN_DEPS=(
    # WM + compositor
    bspwm sxhkd picom

    # Bar
    quickshell polybar

    # Notifications
    dunst archcraft-dunst-icons

    # Terminal + shell
    alacritty fish

    # Terminal Helpers 
    starship zoxide eza

    # Apps
    btop geany geany-plugins mpv neovim plank ranger rofi

    # Utilities
    feh matugen imagemagick inotify-tools
    xdo xdotool xclip xorg-xrandr

    # Audio 
    mpd mpc ncmpcpp pulsemixer pavucontrol 

    # Theming 
    lxappearance qt5ct qt6ct kvantum kvantum-qt5 xsettingsd

    # Lockscreen 
    betterlockscreen 

    # network 
    network-manager-applet 

    # auth polkit 

    xfce-polkit 

    # Archcraft core
    archcraft-mirrorlist
    archcraft-bspwm
    archcraft-fonts
    archcraft-artworks
    archcraft-backgrounds
    archcraft-backgrounds-branding
    archcraft-config-geany
    archcraft-config-qt
    archcraft-neofetch
    archcraft-ranger
    archcraft-scripts
    archcraft-arandr

    # GTK Themes
    archcraft-gtk-theme-adapta    archcraft-gtk-theme-arc
    archcraft-gtk-theme-blade     archcraft-gtk-theme-catppuccin
    archcraft-gtk-theme-cyberpunk archcraft-gtk-theme-dracula
    archcraft-gtk-theme-easy      archcraft-gtk-theme-everforest
    archcraft-gtk-theme-fluent    archcraft-gtk-theme-groot
    archcraft-gtk-theme-gruvbox   archcraft-gtk-theme-hack
    archcraft-gtk-theme-juno      archcraft-gtk-theme-kanagawa
    archcraft-gtk-theme-kripton   archcraft-gtk-theme-manhattan
    archcraft-gtk-theme-material  archcraft-gtk-theme-nightfox
    archcraft-gtk-theme-nordic    archcraft-gtk-theme-orchis
    archcraft-gtk-theme-qogir     archcraft-gtk-theme-rick
    archcraft-gtk-theme-slime     archcraft-gtk-theme-spark
    archcraft-gtk-theme-sweet     archcraft-gtk-theme-tokyonight
    archcraft-gtk-theme-valyrian  archcraft-gtk-theme-wave
    archcraft-gtk-theme-white     archcraft-gtk-theme-windows

    # Icon Themes
    archcraft-icons-arc          archcraft-icons-ars
    archcraft-icons-azure        archcraft-icons-beautyline
    archcraft-icons-breeze       archcraft-icons-candy
    archcraft-icons-colloid      archcraft-icons-fluent
    archcraft-icons-glassy       archcraft-icons-hack
    archcraft-icons-luna         archcraft-icons-luv
    archcraft-icons-mojavecircle archcraft-icons-nordic
    archcraft-icons-numix        archcraft-icons-papirus
    archcraft-icons-qogir        archcraft-icons-sweetfolders
    archcraft-icons-tela         archcraft-icons-vimix
    archcraft-icons-white        archcraft-icons-win11
    archcraft-icons-zafiro       archcraft-icons-zafironord

    # Cursors
    archcraft-cursor-bibata   archcraft-cursor-breezex
    archcraft-cursor-colloid  archcraft-cursor-fluent
    archcraft-cursor-future   archcraft-cursor-layan
    archcraft-cursor-lyra     archcraft-cursor-material
    archcraft-cursor-nordic   archcraft-cursor-pear
    archcraft-cursor-qogirr   archcraft-cursor-simple
    archcraft-cursor-sweet    archcraft-cursor-vimix
    archcraft-cursor-windows
)

# ── AUR Deps ──────────────────────────────────────────────────────────────────
AUR_DEPS=(
    vicinae-bin neofetch
)

# ── Install ───────────────────────────────────────────────────────────────────
echo ":: Installing pacman deps..."
sudo pacman -S --needed "${PACMAN_DEPS[@]}"

echo ":: Installing AUR deps..."
yay -S --needed "${AUR_DEPS[@]}"

echo ":: Done."
