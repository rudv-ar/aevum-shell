#!/bin/bash
# ~/.config/aevum/deps.sh
# Usage: deps <command> [subcommand] [flags]

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GRN='\033[0;32m'
YLW='\033[0;33m'
BLU='\033[0;34m'
PRP='\033[0;37m'
CYN='\033[0;36m'
WHT='\033[1;37m'
DIM='\033[2m'
BLD='\033[1m'
RST='\033[0m'

# ── Header ────────────────────────────────────────────────────────────────────
header() {
    clear
    echo -e "${PRP}"
    echo -e "  ░█████╗░███████╗██╗░░░██╗██╗░░░██╗███╗░░░███╗"
    echo -e "  ██╔══██╗██╔════╝██║░░░██║██║░░░██║████╗░████║"
    echo -e "  ███████║█████╗░░╚██╗░██╔╝██║░░░██║██╔████╔██║"
    echo -e "  ██╔══██║██╔══╝░░░╚████╔╝░██║░░░██║██║╚██╔╝██║"
    echo -e "  ██║░░██║███████╗░░╚██╔╝░░╚██████╔╝██║░╚═╝░██║"
    echo -e "  ╚═╝░░╚═╝╚══════╝░░░╚═╝░░░╚═════╝░╚═╝░░░░╚═╝${RST}"
    echo -e "  ${DIM}<<shell — dependency manager @ bspwm >>${RST}"
    echo -e "  ${DIM}──────────────────────────────────────────${RST}"
    echo ""
}

# ── Deps ──────────────────────────────────────────────────────────────────────
PACMAN_DEPS=(
    # essentials
    bspwm sxhkd picom

    # bars
    quickshell polybar

    # dunst
    dunst archcraft-dunst-icons

    # terminal things
    alacritty fish
    starship zoxide eza

    # tools
    btop geany geany-plugins mpv neovim plank ranger rofi

    # image and theming
    feh matugen imagemagick inotify-tools

    # xorg deps
    xdo xdotool xclip xorg-xrandr

    # media
    mpd mpc ncmpcpp pulsemixer pavucontrol

    # appearance
    lxappearance qt5ct qt6ct kvantum kvantum-qt5 xsettingsd

    # lockscreen
    betterlockscreen

    # network and auth
    network-manager-applet
    xfce-polkit

    # mirrorlist + fonts
    archcraft-mirrorlist
    archcraft-fonts

    # archcraft themes
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

    # archcraft icons
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

    # archcraft cursors
    archcraft-cursor-bibata   archcraft-cursor-breezex
    archcraft-cursor-colloid  archcraft-cursor-fluent
    archcraft-cursor-future   archcraft-cursor-layan
    archcraft-cursor-lyra     archcraft-cursor-material
    archcraft-cursor-nordic   archcraft-cursor-pear
    archcraft-cursor-qogirr   archcraft-cursor-simple
    archcraft-cursor-sweet    archcraft-cursor-vimix
    archcraft-cursor-windows
)

AUR_DEPS=(
    vicinae-bin
    neofetch
    cmatrix
)

# ── Helpers ───────────────────────────────────────────────────────────────────
info()    { echo -e "  ${BLU}::${RST} $1"; }
success() { echo -e "  ${GRN}✓${RST}  $1"; }
warn()    { echo -e "  ${YLW}!${RST}  $1"; }
error()   { echo -e "  ${RED}✗${RST}  $1"; }
section() { echo -e "\n  ${PRP}▸${RST} ${BLD}$1${RST}\n"; }

usage() {
    header
    echo -e "  ${WHT}Usage:${RST} deps <command> [subcommand] [flags]\n"
    echo -e "  ${PRP}install${RST}"
    echo -e "    ${DIM}deps install all${RST}            install everything ${DIM}(--needed)${RST}"
    echo -e "    ${DIM}deps install pacman${RST}         install pacman deps ${DIM}(--needed)${RST}"
    echo -e "    ${DIM}deps install yay${RST}            install AUR deps ${DIM}(--needed)${RST}"
    echo -e "    ${DIM}deps install <pkg> [-f]${RST}     install specific package ${DIM}(-f to force)${RST}"
    echo ""
    echo -e "  ${PRP}verify${RST}"
    echo -e "    ${DIM}deps verify all${RST}             verify all deps"
    echo -e "    ${DIM}deps verify pacman${RST}          verify pacman deps only"
    echo -e "    ${DIM}deps verify yay${RST}             verify AUR deps only"
    echo ""
    echo -e "  ${PRP}setup${RST}"
    echo -e "    ${DIM}deps setup keyring${RST}          setup repo + keyring ${DIM}(--needed)${RST}"
    echo -e "    ${DIM}deps setup keyring -f${RST}       force reinstall keyring"
    echo -e "    ${DIM}deps setup keyring -r${RST}       remove archcraft repo + keyring"
    echo ""
    echo -e "  ${DIM}Run without arguments to open interactive menu.${RST}"
    echo ""
}

# ── Core actions ──────────────────────────────────────────────────────────────
_setup_repo() {
    local force="${1:-}"
    section "Archcraft Repo"
    if grep -q "\[archcraft\]" /etc/pacman.conf; then
        success "Archcraft repo already present"
    else
        info "Writing mirrorlist → /etc/pacman.d/archcraft-mirrorlist"
        sudo tee /etc/pacman.d/archcraft-mirrorlist > /dev/null <<'EOF'
############### Archcraft Mirrorlist ###############

## Worldwide (Github)
Server = https://packages.archcraft.io/$arch
EOF
        info "Appending [archcraft] to /etc/pacman.conf"
        sudo tee -a /etc/pacman.conf > /dev/null <<'EOF'

[archcraft]
SigLevel = Optional TrustAll
Include = /etc/pacman.d/archcraft-mirrorlist
EOF
        info "Syncing databases..."
        sudo pacman -Syu
        success "Repo configured"
    fi
}

_setup_keyring() {
    local force="${1:-}"
    section "Keyrings"
    if [[ "$force" == "-f" ]]; then
        info "Force reinstalling keyrings..."
        sudo pacman -S archlinux-keyring
    else
        info "Installing keyrings..."
        sudo pacman -S --needed archlinux-keyring
    fi
    success "Keyrings ready"
}

_remove_keyring() {
    section "Remove Archcraft Repo + Keyring"
    warn "This will remove [archcraft] from /etc/pacman.conf and delete the mirrorlist."
    printf "  Are you sure? [y/N] "; read -r confirm
    [[ "${confirm,,}" != "y" ]] && warn "Aborted." && return

    info "Removing [archcraft] block from /etc/pacman.conf..."
    sudo sed -i '/^\[archcraft\]/,/^$/d' /etc/pacman.conf
    sudo rm -f /etc/pacman.d/archcraft-mirrorlist
    sudo pacman -Sy
    success "Archcraft repo removed"
}

_install_pacman() {
    local force="${1:-}"
    section "Installing Pacman Deps"
    if [[ "$force" == "-f" ]]; then
        info "Force installing pacman deps..."
        sudo pacman -S "${PACMAN_DEPS[@]}"
    else
        sudo pacman -S --needed "${PACMAN_DEPS[@]}"
    fi
    success "Pacman deps done"
}

_install_yay() {
    local force="${1:-}"
    section "Installing AUR Deps"
    if [[ "$force" == "-f" ]]; then
        info "Force installing AUR deps..."
        yay -S "${AUR_DEPS[@]}"
    else
        yay -S --needed "${AUR_DEPS[@]}"
    fi
    success "AUR deps done"
}

_install_pkg() {
    local pkg="$1"
    local force="${2:-}"
    section "Installing: $pkg"

    # check if it's a known dep
    local known=false
    for d in "${PACMAN_DEPS[@]}" "${AUR_DEPS[@]}"; do
        [[ "$d" == "$pkg" ]] && known=true && break
    done
    [[ "$known" == false ]] && warn "$pkg is not in the aevum dep list — installing anyway"

    if [[ "$force" == "-f" ]]; then
        info "Force installing $pkg..."
        if pacman -Si "$pkg" &>/dev/null; then
            sudo pacman -S "$pkg"
        else
            yay -S "$pkg"
        fi
    else
        if pacman -Si "$pkg" &>/dev/null; then
            sudo pacman -S --needed "$pkg"
        else
            yay -S --needed "$pkg"
        fi
    fi
    success "$pkg installed"
}

_verify() {
    local scope="${1:-all}"
    section "Verifying Deps — $scope"
    local missing=()
    local check_pacman=false
    local check_yay=false

    [[ "$scope" == "all" || "$scope" == "pacman" ]] && check_pacman=true
    [[ "$scope" == "all" || "$scope" == "yay"    ]] && check_yay=true

    if $check_pacman; then
        for dep in "${PACMAN_DEPS[@]}"; do
            pacman -Qq "$dep" &>/dev/null || missing+=("${YLW}[pacman]${RST} $dep")
        done
    fi
    if $check_yay; then
        for dep in "${AUR_DEPS[@]}"; do
            pacman -Qq "$dep" &>/dev/null || missing+=("${CYN}[aur]${RST}    $dep")
        done
    fi

    if [[ ${#missing[@]} -eq 0 ]]; then
        success "All checked deps are installed"
    else
        warn "${#missing[@]} missing package(s):"
        for m in "${missing[@]}"; do
            echo -e "    ${RED}✗${RST}  $m"
        done
    fi
}

# ── Interactive menu ──────────────────────────────────────────────────────────
preview_deps() {
    local label="$1"; shift
    local deps=("$@")
    section "Queued for install — $label"
    local i=0
    for dep in "${deps[@]}"; do
        printf "  \033[2m%-35s\033[0m" "$dep"
        (( ++i % 2 == 0 )) && echo
    done
    [[ $((i % 2)) -ne 0 ]] && echo
    echo ""
    printf "  Proceed? [Y/n] "; read -r confirm
    [[ "${confirm,,}" == "n" ]] && warn "Skipped." && return 1
    return 0
}

menu() {
    while true; do
        header
        echo -e "  ${WHT}What do you want to do?${RST}\n"
        echo -e "  ${PRP}1.${RST}  Setup repo + keyrings"
        echo -e "  ${PRP}2.${RST}  Install pacman deps"
        echo -e "  ${PRP}3.${RST}  Install AUR deps        ${DIM}(yay)${RST}"
        echo -e "  ${PRP}4.${RST}  Install everything"
        echo -e "  ${PRP}5.${RST}  Verify all deps"
        echo -e "  ${PRP}6.${RST}  Reinstall everything    ${DIM}(force)${RST}"
        echo -e "  ${PRP}q.${RST}  Quit"
        echo ""
        printf "  \033[2m→ \033[0m"; read -r choice
        echo ""
        case "$choice" in
            1) _setup_repo; _setup_keyring ;;
            2) preview_deps "pacman" "${PACMAN_DEPS[@]}" && _install_pacman ;;
            3) preview_deps "yay"    "${AUR_DEPS[@]}"    && _install_yay ;;
            4) _setup_repo; _setup_keyring
               preview_deps "pacman" "${PACMAN_DEPS[@]}" && _install_pacman
               preview_deps "yay"    "${AUR_DEPS[@]}"    && _install_yay ;;
            5) _verify all ;;
            6) _install_pacman -f; _install_yay -f ;;
            q|Q) info "Bye."; exit 0 ;;
            *) warn "Invalid option" ;;
        esac
        echo ""
        printf "  \033[2mPress Enter to return to menu...\033[0m"; read -r
    done
}

# ── CLI dispatcher ────────────────────────────────────────────────────────────
case "${1:-}" in
    install)
        case "${2:-}" in
            all)    _install_pacman "${3:-}"; _install_yay "${3:-}" ;;
            pacman) _install_pacman "${3:-}" ;;
            yay)    _install_yay    "${3:-}" ;;
            "")     error "Specify: all, pacman, yay, or <package>"; exit 1 ;;
            *)      _install_pkg "${2}" "${3:-}" ;;
        esac
        ;;
    verify)
        case "${2:-}" in
            all|pacman|yay) _verify "${2}" ;;
            "") _verify all ;;
            *) error "Unknown scope: ${2}. Use all, pacman, or yay."; exit 1 ;;
        esac
        ;;
    setup)
        case "${2:-}" in
            keyring)
                case "${3:-}" in
                    -f) _setup_repo; _setup_keyring -f ;;
                    -r) _remove_keyring ;;
                    *)  _setup_repo; _setup_keyring ;;
                esac
                ;;
            "") error "Specify: keyring"; exit 1 ;;
            *) error "Unknown setup target: ${2}"; exit 1 ;;
        esac
        ;;
    help|--help|-h) usage ;;
    "") menu ;;
    *) error "Unknown command: ${1}"; echo ""; usage; exit 1 ;;
esac
