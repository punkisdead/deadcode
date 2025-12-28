#!/bin/bash
# Deadcode - Bluetooth Installation
# Installs bluetooth support

install_bluetooth() {
    header "Installing bluetooth support"
    install_from_list "${DEADCODE_PATH}/packages/bluetooth.txt"

    # Enable bluetooth service
    ensure_service "bluetooth"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/../helpers/all.sh"
    install_bluetooth
fi
