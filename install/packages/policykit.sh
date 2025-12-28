#!/bin/bash
# Deadcode - Policykit Installation
# Installs GNOME Policykit agent for authentication dialogs

install_policykit() {
    header "Installing policykit agent"
    install_from_list "${DEADCODE_PATH}/packages/policykit.txt"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/../helpers/all.sh"
    install_policykit
fi
