#!/bin/bash
# Deadcode - Desktop Utilities Installation
# Installs rofi, dunst, feh, and other utilities

install_utilities() {
    header "Installing desktop utilities"
    install_from_list "${DEADCODE_PATH}/packages/utilities.txt"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/../helpers/all.sh"
    install_utilities
fi
