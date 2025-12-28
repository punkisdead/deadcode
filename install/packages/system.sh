#!/bin/bash
# Deadcode - System Utilities Installation
# Installs system utilities and enables services

install_system() {
    header "Installing system utilities"
    install_from_list "${DEADCODE_PATH}/packages/system.txt"

    # Enable ACPI daemon
    ensure_service "acpid"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/../helpers/all.sh"
    install_system
fi
