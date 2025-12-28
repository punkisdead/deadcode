#!/bin/bash
# Deadcode - Printing Installation
# Installs CUPS printing support

install_printing() {
    header "Installing printing support"
    install_from_list "${DEADCODE_PATH}/packages/printing.txt"

    # Enable CUPS service
    ensure_service "cups"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/../helpers/all.sh"
    install_printing
fi
