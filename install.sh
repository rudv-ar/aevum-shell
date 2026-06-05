#!/bin/bash
# ~/.config/aevum/install.sh

AEVUM="$HOME/.config/aevum"
INSTALLER="$AEVUM/cli/installer"

# ── Helpers ───────────────────────────────────────────────────────────────────
info()    { echo -e "  \033[0;34m::\033[0m $1"; }
success() { echo -e "  \033[0;32m✓\033[0m  $1"; }
warn()    { echo -e "  \033[0;33m!\033[0m  $1"; }
error()   { echo -e "  \033[0;31m✗\033[0m  $1"; }
section() { echo -e "\n  \033[0;37m▸\033[0m \033[1m$1\033[0m\n"; }

# ── Link + verify + force if needed ──────────────────────────────────────────
_link_verified() {
    local script="$1"
    local target="${2:-}"
    local add_cmd="add-all"
    local verify_cmd="verify-all"

    if [[ -n "$target" ]]; then
        add_cmd="add $target"
        verify_cmd="verify $target"
    fi

    info "Linking ${target:-all}..."
    bash "$script" $add_cmd

    info "Verifying ${target:-all}..."
    if bash "$script" $verify_cmd 2>&1 | grep -q "✗\|!"; then
        warn "${target:-all}: verification failed — force relinking..."
        bash "$script" $add_cmd -f
        success "${target:-all}: force relinked"
    else
        success "${target:-all}: verified"
    fi
}

# ── 1. Install fish ───────────────────────────────────────────────────────────
section "Fish Shell"
info "Installing fish..."
sudo pacman -S --needed fish

FISH_PATH="$(which fish)"

info "Setting fish as default shell for $USER..."
sudo chsh -s "$FISH_PATH" "$USER"

info "Setting fish as default shell for root..."
sudo chsh -s "$FISH_PATH" root

success "Fish set as default shell"

# ── 2. Bootstrap fish config ──────────────────────────────────────────────────
section "Fish Config"
_link_verified "$INSTALLER/config-linker.sh" fish

# ── 3. Fish PATH ──────────────────────────────────────────────────────────────
section "Fish PATH"
info "Setting global PATH entries..."
fish -c "fish_add_path --global /usr/bin"
fish -c "fish_add_path --global /usr/local/bin"
fish -c "fish_add_path --global /usr/sbin"
fish -c "fish_add_path --global /usr/local/sbin"
fish -c "fish_add_path --global /bin"
fish -c "fish_add_path --global /sbin"
fish -c "fish_add_path --global $HOME/.local/bin"
fish -c "fish_add_path --global $HOME/.local/share/bin"
fish -c "fish_add_path --global $HOME/.cargo/bin"
success "Fish PATH configured"

# ── 4. Keyring + repo ─────────────────────────────────────────────────────────
section "Archcraft Repo + Keyring"
bash "$INSTALLER/deps.sh" setup keyring

# ── 5. Deps ───────────────────────────────────────────────────────────────────
section "Dependencies"
info "Installing all deps..."
bash "$INSTALLER/deps.sh" install all

info "Verifying deps..."
if bash "$INSTALLER/deps.sh" verify all 2>&1 | grep -q "✗\|!"; then
    warn "Some deps missing — force installing..."
    bash "$INSTALLER/deps.sh" install all -f
else
    success "All deps verified"
fi

# ── 6. Link configs ───────────────────────────────────────────────────────────
section "Config Symlinks"
_link_verified "$INSTALLER/config-linker.sh"

# ── 7. Link local ─────────────────────────────────────────────────────────────
section "Local Symlinks"
_link_verified "$INSTALLER/local-linker.sh"

section "Set Wallpaper"
mkdir -p "$HOME/Pictures/Wallpapers"
cp -r "$AEVUM/assets/ign_batman.png" "$HOME/Pictures/Wallpapers/ign_batman.png"
bash "$HOME/.config/aevum/config/bspwm/apps/wallpicker/generate-cache.sh" "$HOME/.config/aevum/config/bspwm/apps/wallpicker"
bash "$HOME/.config/aevum/config/bspwm/apps/wallpicker/set-wallpaper.sh" "$HOME/Pictures/Wallpapers/ign_batman.png"

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo -e "  \033[0;32m✓\033[0m  Aevum fully installed. Open a new fish shell and you're good."
echo ""
