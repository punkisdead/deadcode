#!/bin/bash
# Deadcode - Development Libraries Installation
# Installs development libraries for building software

install_devlibs() {
    header "Installing development libraries"
    install_from_list "${DEADCODE_PATH}/packages/devlibs.txt"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/../helpers/all.sh"
    install_devlibs
fi
