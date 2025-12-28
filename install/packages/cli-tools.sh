#!/bin/bash
# Deadcode - CLI Tools Installation
# Installs GitHub CLI, gcloud CLI, lazygit, lazydocker, and Claude Code

install_cli_tools() {
    header "Installing CLI tools"

    install_github_cli
    install_gcloud_cli
    install_lazygit
    install_lazydocker
    install_claude_code
}

install_github_cli() {
    header "Installing GitHub CLI"

    if command_exists gh; then
        debug "GitHub CLI already installed"
        return 0
    fi

    # Add GitHub CLI repository
    subheader "Adding GitHub CLI repository"
    if [[ ! -f /etc/apt/keyrings/githubcli-archive-keyring.gpg ]]; then
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
            sudo dd of=/etc/apt/keyrings/githubcli-archive-keyring.gpg
        sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
    fi

    if [[ ! -f /etc/apt/sources.list.d/github-cli.list ]]; then
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | \
            sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt-get update >> "$LOG_FILE" 2>&1
    fi

    ensure_package gh
    success "GitHub CLI installed"
}

install_gcloud_cli() {
    header "Installing Google Cloud CLI"

    if command_exists gcloud; then
        debug "gcloud CLI already installed"
        return 0
    fi

    # Install prerequisites
    ensure_package apt-transport-https
    ensure_package ca-certificates
    ensure_package gnupg
    ensure_package curl

    # Add Google Cloud GPG key
    subheader "Adding Google Cloud GPG key"
    if [[ ! -f /etc/apt/keyrings/cloud.google.gpg ]]; then
        curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
            sudo gpg --dearmor -o /etc/apt/keyrings/cloud.google.gpg
        sudo chmod a+r /etc/apt/keyrings/cloud.google.gpg
    fi

    # Add Google Cloud repository
    subheader "Adding Google Cloud repository"
    if [[ ! -f /etc/apt/sources.list.d/google-cloud-sdk.list ]]; then
        echo "deb [signed-by=/etc/apt/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | \
            sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list > /dev/null
        sudo apt-get update >> "$LOG_FILE" 2>&1
    fi

    ensure_package google-cloud-cli
    success "Google Cloud CLI installed"
}

install_lazygit() {
    header "Installing lazygit"

    if command_exists lazygit; then
        debug "lazygit already installed"
        return 0
    fi

    local lazygit_version
    lazygit_version=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')

    if [[ -z "$lazygit_version" ]]; then
        error "Failed to get lazygit version"
        return 1
    fi

    subheader "Downloading lazygit v${lazygit_version}"
    local tmp_dir="/tmp/lazygit-install"
    mkdir -p "$tmp_dir"

    curl -Lo "${tmp_dir}/lazygit.tar.gz" \
        "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${lazygit_version}_Linux_x86_64.tar.gz"

    tar xf "${tmp_dir}/lazygit.tar.gz" -C "$tmp_dir"
    sudo install "${tmp_dir}/lazygit" /usr/local/bin

    rm -rf "$tmp_dir"
    success "lazygit installed"
}

install_lazydocker() {
    header "Installing lazydocker"

    if command_exists lazydocker; then
        debug "lazydocker already installed"
        return 0
    fi

    local lazydocker_version
    lazydocker_version=$(curl -s "https://api.github.com/repos/jesseduffield/lazydocker/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')

    if [[ -z "$lazydocker_version" ]]; then
        error "Failed to get lazydocker version"
        return 1
    fi

    subheader "Downloading lazydocker v${lazydocker_version}"
    local tmp_dir="/tmp/lazydocker-install"
    mkdir -p "$tmp_dir"

    curl -Lo "${tmp_dir}/lazydocker.tar.gz" \
        "https://github.com/jesseduffield/lazydocker/releases/latest/download/lazydocker_${lazydocker_version}_Linux_x86_64.tar.gz"

    tar xf "${tmp_dir}/lazydocker.tar.gz" -C "$tmp_dir"
    sudo install "${tmp_dir}/lazydocker" /usr/local/bin

    rm -rf "$tmp_dir"
    success "lazydocker installed"
}

install_claude_code() {
    header "Installing Claude Code"

    # Check if npm is available
    if ! command_exists npm; then
        warn "npm not found - skipping Claude Code installation"
        warn "Install Node.js/npm first, then run: npm install -g @anthropic-ai/claude-code"
        return 0
    fi

    if command_exists claude; then
        debug "Claude Code already installed"
        return 0
    fi

    subheader "Installing Claude Code via npm"
    if npm install -g @anthropic-ai/claude-code >> "$LOG_FILE" 2>&1; then
        success "Claude Code installed"
    else
        error "Failed to install Claude Code"
        return 1
    fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/../helpers/all.sh"
    install_cli_tools
fi
