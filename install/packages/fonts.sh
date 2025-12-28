#!/bin/bash
# Deadcode - Fonts Installation
# Installs system fonts and Nerd Fonts

# Nerd Fonts version to install
NERD_FONTS_VERSION="v3.3.0"

# Fonts to install from Nerd Fonts
NERD_FONTS=(
    "JetBrainsMono"
    "FiraCode"
    "Hack"
    "SourceCodePro"
    "DejaVuSansMono"
    "Meslo"
    "CascadiaCode"
)

install_fonts() {
    header "Installing fonts"

    # Install system fonts from packages
    install_from_list "${DEADCODE_PATH}/packages/fonts.txt"

    # Install Nerd Fonts
    install_nerd_fonts
}

install_nerd_fonts() {
    local fonts_dir="${HOME}/.local/share/fonts"
    ensure_dir "$fonts_dir"

    header "Installing Nerd Fonts"

    for font in "${NERD_FONTS[@]}"; do
        install_nerd_font "$font"
    done

    # Update font cache
    subheader "Updating font cache"
    fc-cache -f
    success "Font cache updated"
}

install_nerd_font() {
    local font_name="$1"
    local fonts_dir="${HOME}/.local/share/fonts"
    local font_dir="${fonts_dir}/${font_name}"
    local download_url="https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_FONTS_VERSION}/${font_name}.zip"
    local tmp_file="/tmp/${font_name}.zip"

    # Check if already installed
    if [[ -d "$font_dir" ]] && [[ -n "$(ls -A "$font_dir" 2>/dev/null)" ]]; then
        debug "Nerd Font already installed: $font_name"
        return 0
    fi

    subheader "Installing Nerd Font: $font_name"

    # Download
    if ! wget -q -O "$tmp_file" "$download_url"; then
        error "Failed to download $font_name"
        return 1
    fi

    # Extract
    ensure_dir "$font_dir"
    if unzip -q -o "$tmp_file" -d "$font_dir"; then
        success "Installed $font_name"
        rm -f "$tmp_file"
        return 0
    else
        error "Failed to extract $font_name"
        rm -f "$tmp_file"
        return 1
    fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/../helpers/all.sh"
    install_fonts
fi
