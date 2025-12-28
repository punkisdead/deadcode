#!/bin/bash
# Deadcode - Core Package Installation
# Installs essential system packages

install_core() {
    header "Installing core packages"
    install_from_list "${DEADCODE_PATH}/packages/core.txt"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/../helpers/all.sh"
    install_core
fi
