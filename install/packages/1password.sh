#!/bin/bash
# Deadcode - 1Password Installation
# Installs 1Password from official repository

install_1password() {
    header "Installing 1Password"

    # Check if 1Password is already installed
    if command_exists 1password; then
        debug "1Password already installed"
        return 0
    fi

    # Install prerequisites
    ensure_package curl
    ensure_package gpg

    # Add 1Password GPG key
    subheader "Adding 1Password GPG key"
    if [[ ! -f /etc/apt/keyrings/1password-archive-keyring.gpg ]]; then
        curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
            sudo gpg --dearmor -o /etc/apt/keyrings/1password-archive-keyring.gpg
    fi

    # Add 1Password repository
    subheader "Adding 1Password repository"
    if [[ ! -f /etc/apt/sources.list.d/1password.list ]]; then
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | \
            sudo tee /etc/apt/sources.list.d/1password.list > /dev/null
    fi

    # Add debsig policy for 1Password
    subheader "Configuring package verification"
    sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
    curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | \
        sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol > /dev/null
    sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
    curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
        sudo gpg --dearmor -o /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg 2>/dev/null

    # Update and install
    sudo apt-get update >> "$LOG_FILE" 2>&1
    ensure_package 1password

    # Optionally install CLI
    if confirm "Install 1Password CLI as well?"; then
        ensure_package 1password-cli
    fi

    success "1Password installed"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/../helpers/all.sh"
    install_1password
fi
