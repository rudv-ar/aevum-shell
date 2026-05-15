#!/bin/bash
# ~/.config/aevum/linker.sh

AEVUM="$HOME/.config/aevum/config"
CONFIG="$HOME/.config"

DIRS=(bspwm btop dunst fish geany mpv neofetch nvim plank ranger rofi vicinae)

# ── Helpers ───────────────────────────────────────────────────────────────────
info()    { echo -e "  \033[0;34m::\033[0m $1"; }
success() { echo -e "  \033[0;32m✓\033[0m  $1"; }
warn()    { echo -e "  \033[0;33m!\033[0m  $1"; }
error()   { echo -e "  \033[0;31m✗\033[0m  $1"; }

usage() {
    echo ""
    echo -e "  \033[1;37mUsage:\033[0m linker <command> [app] [flags]"
    echo ""
    echo -e "  \033[0;37madd <app> [-f]\033[0m        symlink app; -f forces even if already linked"
    echo -e "  \033[0;37madd-all [-f]\033[0m          symlink all apps"
    echo -e "  \033[0;37mremove <app> [-f]\033[0m     remove symlink; -f removes even if directory"
    echo -e "  \033[0;37mremove-all [-f]\033[0m       remove all symlinks"
    echo -e "  \033[0;37mverify <app> [-f]\033[0m     check symlink; -f auto-fixes if broken"
    echo -e "  \033[0;37mverify-all [-f]\033[0m       verify all; -f auto-fixes broken ones"
    echo ""
}

# ── Core ──────────────────────────────────────────────────────────────────────
_add() {
    local app="$1"
    local force="${2:-}"
    local src="$AEVUM/$app"
    local dst="$CONFIG/$app"

    if [[ ! -d "$src" ]]; then
        error "$app: not found in aevum/config — skipping"
        return
    fi

    # Already a valid symlink
    if [[ -L "$dst" && -e "$dst" ]]; then
        if [[ "$force" == "-f" ]]; then
            rm -f "$dst"
            ln -s "$src" "$dst"
            success "$app: force relinked"
        else
            info "$app: already linked — skipping"
        fi
        return
    fi

    # Is a real directory
    if [[ -d "$dst" && ! -L "$dst" ]]; then
        warn "$app: real directory exists at $dst — purging and relinking"
        rm -rf "$dst"
        ln -s "$src" "$dst"
        success "$app: purged dir → linked"
        return
    fi

    # Broken symlink or nothing
    [[ -L "$dst" ]] && rm -f "$dst"
    ln -s "$src" "$dst"
    success "$app: linked"
}

_remove() {
    local app="$1"
    local force="${2:-}"
    local dst="$CONFIG/$app"

    if [[ ! -e "$dst" && ! -L "$dst" ]]; then
        warn "$app: nothing at $dst"
        return
    fi

    if [[ -L "$dst" ]]; then
        rm -f "$dst"
        success "$app: symlink removed"
        return
    fi

    if [[ -d "$dst" ]]; then
        if [[ "$force" == "-f" ]]; then
            rm -rf "$dst"
            success "$app: directory force removed"
        else
            warn "$app: $dst is a real directory — use -f to remove"
        fi
        return
    fi
}

_verify() {
    local app="$1"
    local force="${2:-}"
    local src="$AEVUM/$app"
    local dst="$CONFIG/$app"

    if [[ -L "$dst" && -e "$dst" ]]; then
        success "$app: symlink valid → $dst"
    elif [[ -L "$dst" && ! -e "$dst" ]]; then
        warn "$app: broken symlink"
        if [[ "$force" == "-f" ]]; then
            rm -f "$dst"
            ln -s "$src" "$dst"
            success "$app: auto-fixed"
        fi
    elif [[ -d "$dst" ]]; then
        warn "$app: real directory (not a symlink)"
    else
        error "$app: not found at $dst"
        if [[ "$force" == "-f" ]]; then
            if [[ -d "$src" ]]; then
                ln -s "$src" "$dst"
                success "$app: auto-linked"
            else
                error "$app: source also missing in aevum/config"
            fi
        fi
    fi
}

# ── Dispatcher ────────────────────────────────────────────────────────────────
case "${1:-}" in
    add)
        [[ -z "${2:-}" ]] && error "Specify an app" && usage && exit 1
        _add "$2" "${3:-}"
        ;;
    add-all)
        for d in "${DIRS[@]}"; do _add "$d" "${2:-}"; done
        ;;
    remove)
        [[ -z "${2:-}" ]] && error "Specify an app" && usage && exit 1
        _remove "$2" "${3:-}"
        ;;
    remove-all)
        for d in "${DIRS[@]}"; do _remove "$d" "${2:-}"; done
        ;;
    verify)
        [[ -z "${2:-}" ]] && error "Specify an app" && usage && exit 1
        _verify "$2" "${3:-}"
        ;;
    verify-all)
        for d in "${DIRS[@]}"; do _verify "$d" "${2:-}"; done
        ;;
    help|--help|-h) usage ;;
    *) error "Unknown command: ${1:-}"; usage; exit 1 ;;
esac
