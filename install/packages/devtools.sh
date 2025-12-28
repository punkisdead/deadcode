#!/bin/bash
# Deadcode - Developer Tools Installation
# Installs fzf, ripgrep, cmake, and other dev tools

install_devtools() {
    header "Installing developer tools"
    install_from_list "${DEADCODE_PATH}/packages/devtools.txt"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/../helpers/all.sh"
    install_devtools
fi
