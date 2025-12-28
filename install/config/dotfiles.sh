#!/bin/bash
# Deadcode - Dotfiles Configuration
# Clones and stows user dotfiles

DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/punkisdead/dotfiles.git}"
DOTFILES_DIR="${HOME}/dotfiles"

# Packages to stow
STOW_PACKAGES=(
    "i3"
    "polybar"
    "picom"
    "dunst"
    "rofi"
    "alacritty"
    "kitty"
    "gtk-3.0"
    "backgrounds"
    "zsh"
)

setup_dotfiles() {
    header "Setting up dotfiles"

    # Clone or update dotfiles
    if [[ -d "$DOTFILES_DIR" ]]; then
        subheader "Updating existing dotfiles"
        cd "$DOTFILES_DIR"
        git pull --autostash || warn "Could not update dotfiles"
    else
        subheader "Cloning dotfiles repository"
        if git clone "$DOTFILES_REPO" "$DOTFILES_DIR"; then
            success "Cloned dotfiles"
        else
            error "Failed to clone dotfiles"
            return 1
        fi
    fi

    # Ensure stow is installed
    ensure_package stow

    # Stow each package
    cd "$DOTFILES_DIR"
    for pkg in "${STOW_PACKAGES[@]}"; do
        stow_package "$pkg"
    done

    success "Dotfiles configured"
}

stow_package() {
    local pkg="$1"

    if [[ ! -d "${DOTFILES_DIR}/${pkg}" ]]; then
        debug "Stow package not found: $pkg"
        return 0
    fi

    subheader "Stowing $pkg"

    # Use --restow to handle updates properly
    if stow -R "$pkg" 2>/dev/null; then
        success "Stowed $pkg"
    elif stow --adopt "$pkg" 2>/dev/null && stow -R "$pkg" 2>/dev/null; then
        # --adopt takes existing files into the stow directory, then restow
        success "Stowed $pkg (adopted existing files)"
    else
        warn "Could not stow $pkg - may need manual intervention"
    fi
}

unstow_package() {
    local pkg="$1"

    if [[ ! -d "${DOTFILES_DIR}/${pkg}" ]]; then
        return 0
    fi

    cd "$DOTFILES_DIR"
    stow -D "$pkg" 2>/dev/null
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/../helpers/all.sh"
    setup_dotfiles
fi
