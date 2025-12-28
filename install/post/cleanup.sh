#!/bin/bash
# Deadcode - Post-Install Cleanup
# Cleans up temporary files and caches

cleanup() {
    header "Cleaning up"

    # Clean apt cache
    subheader "Cleaning apt cache"
    sudo apt-get clean

    # Remove downloaded .deb files
    sudo apt-get autoclean

    # Remove unused packages
    subheader "Removing unused packages"
    sudo apt-get autoremove -y

    success "Cleanup complete"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/../helpers/all.sh"
    cleanup
fi
