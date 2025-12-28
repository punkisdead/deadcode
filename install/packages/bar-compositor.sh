#!/bin/bash
# Deadcode - Bar and Compositor Installation
# Installs polybar and picom

install_bar_compositor() {
    header "Installing polybar and picom"
    install_from_list "${DEADCODE_PATH}/packages/bar-compositor.txt"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/../helpers/all.sh"
    install_bar_compositor
fi
