#!/bin/bash
# Deadcode - Theme Configuration
# Sets up the theme system with symlink-based switching

THEMES_SOURCE="${DEADCODE_PATH}/themes"
THEMES_DEST="${HOME}/.config/deadcode/themes"
CURRENT_THEME_LINK="${HOME}/.config/deadcode/current/theme"
DEFAULT_THEME="nord"

setup_themes() {
    header "Setting up themes"

    # Create theme directories
    ensure_dir "$THEMES_DEST"
    ensure_dir "$(dirname "$CURRENT_THEME_LINK")"

    # Copy themes from source
    copy_themes

    # Set default theme if not already set
    if [[ ! -L "$CURRENT_THEME_LINK" ]]; then
        set_default_theme
    else
        success "Theme already configured: $(basename "$(readlink "$CURRENT_THEME_LINK")")"
    fi
}

copy_themes() {
    subheader "Copying themes"

    if [[ ! -d "$THEMES_SOURCE" ]]; then
        warn "Themes source directory not found: $THEMES_SOURCE"
        return 1
    fi

    for theme_dir in "$THEMES_SOURCE"/*/; do
        if [[ -d "$theme_dir" ]]; then
            local theme_name=$(basename "$theme_dir")
            local dest_dir="${THEMES_DEST}/${theme_name}"

            # Copy or update theme
            if [[ -d "$dest_dir" ]]; then
                debug "Theme already exists: $theme_name"
            else
                cp -r "$theme_dir" "$dest_dir"
                debug "Copied theme: $theme_name"
            fi
        fi
    done

    success "Themes copied"
}

set_default_theme() {
    local theme="${1:-$DEFAULT_THEME}"
    local theme_path="${THEMES_DEST}/${theme}"

    if [[ ! -d "$theme_path" ]]; then
        error "Theme not found: $theme"
        return 1
    fi

    subheader "Setting default theme: $theme"
    ensure_symlink "$theme_path" "$CURRENT_THEME_LINK"
    success "Default theme set: $theme"
}

list_themes() {
    if [[ -d "$THEMES_DEST" ]]; then
        for theme_dir in "$THEMES_DEST"/*/; do
            if [[ -d "$theme_dir" ]]; then
                basename "$theme_dir"
            fi
        done
    fi
}

get_current_theme() {
    if [[ -L "$CURRENT_THEME_LINK" ]]; then
        basename "$(readlink "$CURRENT_THEME_LINK")"
    else
        echo "none"
    fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/../helpers/all.sh"
    setup_themes
fi
