#!/bin/bash
# Deadcode - Main Setup Script
# Interactive installer for Debian desktop environment

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DEADCODE_PATH="$SCRIPT_DIR"

# Source helpers
source "${SCRIPT_DIR}/install/helpers/all.sh"

# Version
VERSION="1.0.0"

# Main menu
main_menu() {
    while true; do
        local choice
        choice=$(show_menu "Deadcode Setup" "Select an option:" \
            "1" "Full Installation (recommended)" \
            "2" "Select Components" \
            "3" "Install Themes Only" \
            "4" "Sync Dotfiles" \
            "5" "About" \
            "6" "Exit")

        case "$choice" in
            1) full_installation ;;
            2) component_menu ;;
            3) install_themes_menu ;;
            4) sync_dotfiles ;;
            5) show_about ;;
            6|"") exit 0 ;;
        esac
    done
}

# Full installation
full_installation() {
    if ! confirm "This will install all components. Continue?"; then
        return
    fi

    clear_and_banner

    # Install all packages
    source "${SCRIPT_DIR}/install/packages/all.sh"
    install_all_packages

    # Configure system
    source "${SCRIPT_DIR}/install/config/dotfiles.sh"
    setup_dotfiles

    source "${SCRIPT_DIR}/install/config/themes.sh"
    setup_themes

    source "${SCRIPT_DIR}/install/config/lightdm.sh"
    setup_lightdm

    source "${SCRIPT_DIR}/install/config/plymouth.sh"
    setup_plymouth

    source "${SCRIPT_DIR}/install/config/services.sh"
    setup_services

    # Show completion
    show_complete
}

# Component selection menu
component_menu() {
    local components
    components=$(show_checklist "Select Components" "Choose what to install:" \
        "core" "Core system packages" "ON" \
        "xorg" "X.org display server" "ON" \
        "wm" "i3 window manager" "ON" \
        "bar" "Polybar and Picom" "ON" \
        "utilities" "Desktop utilities (rofi, dunst, etc.)" "ON" \
        "terminals" "Terminal emulators" "ON" \
        "audio" "Audio system (PulseAudio)" "ON" \
        "bluetooth" "Bluetooth support" "ON" \
        "printing" "Printing support (CUPS)" "OFF" \
        "filemanager" "Thunar file manager" "ON" \
        "network" "Network management" "ON" \
        "fonts" "Nerd Fonts" "ON" \
        "policykit" "Policykit agent" "ON" \
        "system" "System utilities" "ON" \
        "devtools" "Developer tools (fzf, ripgrep, cmake, etc.)" "OFF" \
        "devlibs" "Development libraries" "OFF" \
        "docker" "Docker Engine" "OFF" \
        "mise" "mise version manager" "OFF" \
        "cli-tools" "CLI tools (gh, gcloud, lazygit, etc.)" "OFF" \
        "editors" "Editors (Doom Emacs, LazyVim, VS Code)" "OFF" \
        "1password" "1Password password manager" "OFF" \
        "lightdm" "LightDM display manager" "ON" \
        "plymouth" "Plymouth boot splash" "ON" \
        "dotfiles" "User dotfiles" "ON" \
        "themes" "Color themes" "ON")

    if [[ -z "$components" ]]; then
        return
    fi

    clear_and_banner

    # Update package lists
    update_package_lists

    # Install selected components
    for component in $components; do
        # Remove quotes from whiptail output
        component="${component//\"/}"

        case "$component" in
            core)
                source "${SCRIPT_DIR}/install/packages/core.sh"
                install_core
                ;;
            xorg)
                source "${SCRIPT_DIR}/install/packages/xorg.sh"
                install_xorg
                ;;
            wm)
                source "${SCRIPT_DIR}/install/packages/wm.sh"
                install_wm
                ;;
            bar)
                source "${SCRIPT_DIR}/install/packages/bar-compositor.sh"
                install_bar_compositor
                ;;
            utilities)
                source "${SCRIPT_DIR}/install/packages/utilities.sh"
                install_utilities
                ;;
            terminals)
                source "${SCRIPT_DIR}/install/packages/terminals.sh"
                install_terminals
                ;;
            audio)
                source "${SCRIPT_DIR}/install/packages/audio.sh"
                install_audio
                ;;
            bluetooth)
                source "${SCRIPT_DIR}/install/packages/bluetooth.sh"
                install_bluetooth
                ;;
            printing)
                source "${SCRIPT_DIR}/install/packages/printing.sh"
                install_printing
                ;;
            filemanager)
                source "${SCRIPT_DIR}/install/packages/filemanager.sh"
                install_filemanager
                ;;
            network)
                source "${SCRIPT_DIR}/install/packages/network.sh"
                install_network
                ;;
            fonts)
                source "${SCRIPT_DIR}/install/packages/fonts.sh"
                install_fonts
                ;;
            policykit)
                source "${SCRIPT_DIR}/install/packages/policykit.sh"
                install_policykit
                ;;
            system)
                source "${SCRIPT_DIR}/install/packages/system.sh"
                install_system
                ;;
            devtools)
                source "${SCRIPT_DIR}/install/packages/devtools.sh"
                install_devtools
                ;;
            devlibs)
                source "${SCRIPT_DIR}/install/packages/devlibs.sh"
                install_devlibs
                ;;
            docker)
                source "${SCRIPT_DIR}/install/packages/docker.sh"
                install_docker
                ;;
            mise)
                source "${SCRIPT_DIR}/install/packages/mise.sh"
                install_mise
                ;;
            cli-tools)
                source "${SCRIPT_DIR}/install/packages/cli-tools.sh"
                install_cli_tools
                ;;
            editors)
                source "${SCRIPT_DIR}/install/packages/editors.sh"
                install_editors
                ;;
            1password)
                source "${SCRIPT_DIR}/install/packages/1password.sh"
                install_1password
                ;;
            lightdm)
                source "${SCRIPT_DIR}/install/config/lightdm.sh"
                setup_lightdm
                ;;
            plymouth)
                source "${SCRIPT_DIR}/install/config/plymouth.sh"
                setup_plymouth
                ;;
            dotfiles)
                source "${SCRIPT_DIR}/install/config/dotfiles.sh"
                setup_dotfiles
                ;;
            themes)
                source "${SCRIPT_DIR}/install/config/themes.sh"
                setup_themes
                ;;
        esac
    done

    show_message "Installation Complete" "Selected components have been installed."
}

# Theme installation menu
install_themes_menu() {
    source "${SCRIPT_DIR}/install/config/themes.sh"
    setup_themes

    # Offer to set a theme
    local themes
    themes=$(show_menu "Select Default Theme" "Choose a theme to apply:" \
        "nord" "Nord - Arctic, north-bluish color palette" \
        "catppuccin" "Catppuccin Mocha - Soothing pastel dark theme" \
        "catppuccin-latte" "Catppuccin Latte - Soothing pastel light theme" \
        "gruvbox" "Gruvbox Dark - Retro groove color scheme" \
        "gruvbox-light" "Gruvbox Light - Retro groove light variant" \
        "tokyo-night" "Tokyo Night - Clean dark theme" \
        "dracula" "Dracula - Dark theme for vampires" \
        "rose-pine" "Rose Pine - All natural pine, faux fur and soho vibes")

    if [[ -n "$themes" ]]; then
        "${SCRIPT_DIR}/bin/deadcode-theme-set" "$themes"
    fi
}

# Sync dotfiles
sync_dotfiles() {
    source "${SCRIPT_DIR}/install/config/dotfiles.sh"
    setup_dotfiles
    show_message "Dotfiles Synced" "Your dotfiles have been synchronized."
}

# Show about dialog
show_about() {
    show_message "About Deadcode" "
    Deadcode v${VERSION}

    Debian Desktop Environment Configuration

    A modular, idempotent installation system for
    setting up a complete i3-based desktop environment.

    Features:
    - i3 window manager with polybar
    - Multiple color themes
    - Plymouth boot splash
    - GNU Stow dotfiles integration

    GitHub: github.com/punkisdead/deadcode

    Inspired by:
    - drewgrif/bookworm-scripts
    - basecamp/omarchy"
}

# Entry point
main() {
    # Check not running as root
    if [[ $EUID -eq 0 ]]; then
        fatal "Do not run this script as root. Run as your normal user."
    fi

    # Show welcome
    show_welcome "$VERSION"

    # Run main menu
    main_menu
}

# Run
main "$@"
