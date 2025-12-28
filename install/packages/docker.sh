#!/bin/bash
# Deadcode - Docker Installation
# Installs Docker Engine from official repository

install_docker() {
    header "Installing Docker"

    # Check if Docker is already installed
    if command_exists docker; then
        debug "Docker already installed"
        ensure_docker_group
        return 0
    fi

    # Install prerequisites
    subheader "Installing prerequisites"
    ensure_package ca-certificates
    ensure_package curl
    ensure_package gnupg

    # Add Docker's official GPG key
    subheader "Adding Docker GPG key"
    sudo install -m 0755 -d /etc/apt/keyrings
    if [[ ! -f /etc/apt/keyrings/docker.gpg ]]; then
        curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        sudo chmod a+r /etc/apt/keyrings/docker.gpg
    fi

    # Add Docker repository
    subheader "Adding Docker repository"
    if [[ ! -f /etc/apt/sources.list.d/docker.list ]]; then
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
            sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update >> "$LOG_FILE" 2>&1
    fi

    # Install Docker packages
    subheader "Installing Docker packages"
    ensure_package docker-ce
    ensure_package docker-ce-cli
    ensure_package containerd.io
    ensure_package docker-buildx-plugin
    ensure_package docker-compose-plugin

    # Add user to docker group
    ensure_docker_group

    # Enable and start Docker service
    ensure_service docker start

    success "Docker installed successfully"
}

ensure_docker_group() {
    if ! groups "$USER" | grep -q docker; then
        subheader "Adding $USER to docker group"
        sudo usermod -aG docker "$USER"
        warn "Log out and back in for docker group membership to take effect"
    fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/../helpers/all.sh"
    install_docker
fi
