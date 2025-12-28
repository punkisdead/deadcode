#!/bin/bash
# Deadcode - Terminal Emulators Installation
# Installs alacritty and kitty

install_terminals() {
    header "Installing terminal emulators"
    install_from_list "${DEADCODE_PATH}/packages/terminals.txt"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/../helpers/all.sh"
    install_terminals
fi
