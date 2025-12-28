#!/bin/bash
# Deadcode - File Manager Installation
# Installs Thunar and plugins

install_filemanager() {
    header "Installing file manager"
    install_from_list "${DEADCODE_PATH}/packages/filemanager.txt"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/../helpers/all.sh"
    install_filemanager
fi
