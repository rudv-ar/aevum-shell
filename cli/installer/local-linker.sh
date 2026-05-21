#!/bin/bash
# ~/.config/aevum/local-linker.sh

AEVUM_LOCAL="$HOME/.config/aevum/local"
LOCAL="$HOME/.local"

# ── Helpers ───────────────────────────────────────────────────────────────────
info()    { echo -e "  \033[0;34m::\033[0m $1"; }
success() { echo -e "  \033[0;32m✓\033[0m  $1"; }
warn()    { echo -e "  \033[0;33m!\033[0m  $1"; }
error()   { echo -e "  \033[0;31m✗\033[0m  $1"; }

usage() {
    echo ""
    echo -e "  \033[1;37mUsage:\033[0m local-linker <command> [target] [flags]"
    echo ""
    echo -e "  \033[0;37madd <bin|share> [-f]\033[0m      symlink all entries; -f forces relink"
    echo -e "  \033[0;37madd-all [-f]\033[0m              symlink bin/* and share/*"
    echo -e "  \033[0;37mremove <bin|share> [-f]\033[0m   remove symlinks; -f removes real files too"
    echo -e "  \033[0;37mremove-all [-f]\033[0m           remove all symlinks from bin and share"
    echo -e "  \033[0;37mverify <bin|share> [-f]\033[0m   check symlinks; -f auto-fixes broken"
    echo -e "  \033[0;37mverify-all [-f]\033[0m           verify bin and share; -f auto-fixes"
    echo ""
}

# ── Core ──────────────────────────────────────────────────────────────────────
_add_group() {
    local group="$1"
    local force="${2:-}"
    local src_dir="$AEVUM_LOCAL/$group"
    local dst_dir="$LOCAL/$group"

    if [[ ! -d "$src_dir" ]]; then
        error "$group: not found in aevum/local — skipping"
        return
    fi

    mkdir -p "$dst_dir"

    while IFS= read -r -d '' src; do
        local name
        name="$(basename "$src")"
        local dst="$dst_dir/$name"

        if [[ -L "$dst" && -e "$dst" ]]; then
            if [[ "$force" == "-f" ]]; then
                rm -f "$dst"
                ln -s "$src" "$dst"
                success "$group/$name: force relinked"
            else
                info "$group/$name: already linked — skipping"
            fi
            continue
        fi

        if [[ -e "$dst" && ! -L "$dst" ]]; then
            warn "$group/$name: real file/dir exists — skipping (use -f to override)"
            continue
        fi

        [[ -L "$dst" ]] && rm -f "$dst"
        ln -s "$src" "$dst"
        success "$group/$name: linked"
    done < <(find "$src_dir" -mindepth 1 -maxdepth 1 -print0)
}

_remove_group() {
    local group="$1"
    local force="${2:-}"
    local src_dir="$AEVUM_LOCAL/$group"
    local dst_dir="$LOCAL/$group"

    if [[ ! -d "$src_dir" ]]; then
        error "$group: not found in aevum/local — skipping"
        return
    fi

    while IFS= read -r -d '' src; do
        local name
        name="$(basename "$src")"
        local dst="$dst_dir/$name"

        if [[ ! -e "$dst" && ! -L "$dst" ]]; then
            warn "$group/$name: nothing at $dst"
            continue
        fi

        if [[ -L "$dst" ]]; then
            rm -f "$dst"
            success "$group/$name: symlink removed"
            continue
        fi

        if [[ -e "$dst" ]]; then
            if [[ "$force" == "-f" ]]; then
                rm -rf "$dst"
                success "$group/$name: force removed"
            else
                warn "$group/$name: real file/dir — use -f to remove"
            fi
        fi
    done < <(find "$src_dir" -mindepth 1 -maxdepth 1 -print0)
}
_verify_group() {
    local group="$1"
    local force="${2:-}"
    local src_dir="$AEVUM_LOCAL/$group"
    local dst_dir="$LOCAL/$group"

    if [[ ! -d "$src_dir" ]]; then
        error "$group: not found in aevum/local — skipping"
        return
    fi

    while IFS= read -r -d '' src; do
        local name
        name="$(basename "$src")"
        local dst="$dst_dir/$name"

        if [[ -L "$dst" && -e "$dst" ]]; then
            success "$group/$name: symlink valid → $dst"
        elif [[ -L "$dst" && ! -e "$dst" ]]; then
            warn "$group/$name: broken symlink"
            if [[ "$force" == "-f" ]]; then
                rm -f "$dst"
                ln -s "$src" "$dst"
                success "$group/$name: auto-fixed"
            fi
        elif [[ -e "$dst" ]]; then
            warn "$group/$name: real file/dir exists"
            if [[ "$force" == "-f" ]]; then
                rm -rf "$dst"
                ln -s "$src" "$dst"
                success "$group/$name: purged → relinked"
            fi
        else
            error "$group/$name: not found at $dst"
            if [[ "$force" == "-f" ]]; then
                ln -s "$src" "$dst"
                success "$group/$name: auto-linked"
            fi
        fi
    done < <(find "$src_dir" -mindepth 1 -maxdepth 1 -print0)
}

# ── Dispatcher ────────────────────────────────────────────────────────────────
case "${1:-}" in
    add)
        [[ -z "${2:-}" ]] && error "Specify bin or share" && usage && exit 1
        _add_group "$2" "${3:-}"
        ;;
    add-all)
        _add_group "bin" "${2:-}"
        _add_group "share" "${2:-}"
        ;;
    remove)
        [[ -z "${2:-}" ]] && error "Specify bin or share" && usage && exit 1
        _remove_group "$2" "${3:-}"
        ;;
    remove-all)
        _remove_group "bin" "${2:-}"
        _remove_group "share" "${2:-}"
        ;;
    verify)
        [[ -z "${2:-}" ]] && error "Specify bin or share" && usage && exit 1
        _verify_group "$2" "${3:-}"
        ;;
    verify-all)
        _verify_group "bin" "${2:-}"
        _verify_group "share" "${2:-}"
        ;;
    help|--help|-h) usage ;;
    *) error "Unknown command: ${1:-}"; usage; exit 1 ;;
esac
