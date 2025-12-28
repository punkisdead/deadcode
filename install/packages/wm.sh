#!/bin/bash
# Deadcode - Window Manager Installation
# Installs i3 window manager and related tools

install_wm() {
    header "Installing i3 window manager"
    install_from_list "${DEADCODE_PATH}/packages/wm.txt"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/../helpers/all.sh"
    install_wm
fi
