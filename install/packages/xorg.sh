#!/bin/bash
# Deadcode - X.org Installation
# Installs X11 display server and utilities

install_xorg() {
    header "Installing X.org display server"
    install_from_list "${DEADCODE_PATH}/packages/xorg.txt"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/../helpers/all.sh"
    install_xorg
fi
