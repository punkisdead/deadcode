#!/bin/bash
# Deadcode - Install All Packages
# Installs all package categories

PACKAGES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

install_all_packages() {
    header "Installing all packages"

    # Update package lists first
    update_package_lists

    # Install in order
    source "${PACKAGES_DIR}/core.sh"
    install_core

    source "${PACKAGES_DIR}/xorg.sh"
    install_xorg

    source "${PACKAGES_DIR}/wm.sh"
    install_wm

    source "${PACKAGES_DIR}/bar-compositor.sh"
    install_bar_compositor

    source "${PACKAGES_DIR}/utilities.sh"
    install_utilities

    source "${PACKAGES_DIR}/terminals.sh"
    install_terminals

    source "${PACKAGES_DIR}/audio.sh"
    install_audio

    source "${PACKAGES_DIR}/bluetooth.sh"
    install_bluetooth

    source "${PACKAGES_DIR}/printing.sh"
    install_printing

    source "${PACKAGES_DIR}/filemanager.sh"
    install_filemanager

    source "${PACKAGES_DIR}/network.sh"
    install_network

    source "${PACKAGES_DIR}/fonts.sh"
    install_fonts

    source "${PACKAGES_DIR}/policykit.sh"
    install_policykit

    source "${PACKAGES_DIR}/system.sh"
    install_system

    # Developer tools and libraries
    source "${PACKAGES_DIR}/devtools.sh"
    install_devtools

    source "${PACKAGES_DIR}/devlibs.sh"
    install_devlibs

    # Docker
    source "${PACKAGES_DIR}/docker.sh"
    install_docker

    # Mise version manager
    source "${PACKAGES_DIR}/mise.sh"
    install_mise

    # CLI tools (gh, gcloud, lazygit, lazydocker, claude)
    source "${PACKAGES_DIR}/cli-tools.sh"
    install_cli_tools

    success "All packages installed"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/../helpers/all.sh"
    install_all_packages
fi
