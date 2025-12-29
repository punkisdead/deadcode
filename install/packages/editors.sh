#!/bin/bash
# Deadcode - Editors Installation
# Installs Doom Emacs, LazyVim, and VS Code

install_editors() {
    header "Installing editors"

    # Show selection menu
    local editors
    editors=$(show_checklist "Select Editors" "Choose which editors to install:" \
        "doom" "Doom Emacs" "OFF" \
        "lazyvim" "LazyVim (Neovim)" "OFF" \
        "vscode" "Visual Studio Code" "OFF")

    if [[ -z "$editors" ]]; then
        return 0
    fi

    for editor in $editors; do
        editor="${editor//\"/}"
        case "$editor" in
            doom) install_doom_emacs ;;
            lazyvim) install_lazyvim ;;
            vscode) install_vscode ;;
        esac
    done
}

install_doom_emacs() {
    header "Installing Doom Emacs"

    # Install Emacs if not present
    if ! command_exists emacs; then
        subheader "Installing Emacs"
        ensure_package emacs
    fi

    # Install dependencies
    ensure_package git
    ensure_package ripgrep
    ensure_package fd-find

    # Check if Doom is already installed
    if [[ -d "${HOME}/.config/emacs" ]] && [[ -f "${HOME}/.config/emacs/bin/doom" ]]; then
        debug "Doom Emacs already installed"
        subheader "Syncing Doom Emacs"
        "${HOME}/.config/emacs/bin/doom" sync
        return 0
    fi

    # Backup existing emacs config
    if [[ -d "${HOME}/.emacs.d" ]]; then
        warn "Backing up existing .emacs.d"
        mv "${HOME}/.emacs.d" "${HOME}/.emacs.d.bak"
    fi
    if [[ -d "${HOME}/.config/emacs" ]]; then
        warn "Backing up existing .config/emacs"
        mv "${HOME}/.config/emacs" "${HOME}/.config/emacs.bak"
    fi

    # Clone Doom Emacs
    subheader "Cloning Doom Emacs"
    git clone --depth 1 https://github.com/doomemacs/doomemacs "${HOME}/.config/emacs"

    # Run Doom install
    subheader "Running Doom install"
    "${HOME}/.config/emacs/bin/doom" install --no-config

    # Add doom to PATH
    add_doom_to_path

    success "Doom Emacs installed"
}

add_doom_to_path() {
    local bashrc="${HOME}/.bashrc"
    local zshrc="${HOME}/.zshrc"
    local doom_path='export PATH="$HOME/.config/emacs/bin:$PATH"'

    if [[ -f "$bashrc" ]] && ! grep -q ".config/emacs/bin" "$bashrc"; then
        echo "" >> "$bashrc"
        echo "# Doom Emacs" >> "$bashrc"
        echo "$doom_path" >> "$bashrc"
    fi

    if [[ -f "$zshrc" ]] && ! grep -q ".config/emacs/bin" "$zshrc"; then
        echo "" >> "$zshrc"
        echo "# Doom Emacs" >> "$zshrc"
        echo "$doom_path" >> "$zshrc"
    fi
}

install_lazyvim() {
    header "Installing LazyVim"

    # Install Neovim if not present
    if ! command_exists nvim; then
        subheader "Installing Neovim"
        ensure_package neovim
    fi

    # Install dependencies
    ensure_package git
    ensure_package ripgrep
    ensure_package fd-find

    # Warn if Node.js is not available (needed for many LSP servers via Mason)
    if ! command_exists node; then
        warn "Node.js not found - install via mise for Mason LSP support"
    fi

    # Check if LazyVim is already installed
    if [[ -d "${HOME}/.config/nvim" ]] && [[ -f "${HOME}/.config/nvim/lazy-lock.json" ]]; then
        debug "LazyVim already installed"
        return 0
    fi

    # Backup existing nvim config
    if [[ -d "${HOME}/.config/nvim" ]]; then
        warn "Backing up existing nvim config"
        mv "${HOME}/.config/nvim" "${HOME}/.config/nvim.bak"
    fi
    if [[ -d "${HOME}/.local/share/nvim" ]]; then
        mv "${HOME}/.local/share/nvim" "${HOME}/.local/share/nvim.bak"
    fi
    if [[ -d "${HOME}/.local/state/nvim" ]]; then
        mv "${HOME}/.local/state/nvim" "${HOME}/.local/state/nvim.bak"
    fi
    if [[ -d "${HOME}/.cache/nvim" ]]; then
        mv "${HOME}/.cache/nvim" "${HOME}/.cache/nvim.bak"
    fi

    # Clone LazyVim starter
    subheader "Cloning LazyVim starter"
    git clone https://github.com/LazyVim/starter "${HOME}/.config/nvim"
    rm -rf "${HOME}/.config/nvim/.git"

    success "LazyVim installed - run 'nvim' to complete setup"
}

install_vscode() {
    header "Installing Visual Studio Code"

    # Check if VS Code is already installed
    if command_exists code; then
        debug "VS Code already installed"
        return 0
    fi

    # Install prerequisites
    ensure_package wget
    ensure_package gpg

    # Add Microsoft GPG key
    subheader "Adding Microsoft GPG key"
    if [[ ! -f /etc/apt/keyrings/packages.microsoft.gpg ]]; then
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg
        sudo install -D -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
        rm -f /tmp/packages.microsoft.gpg
    fi

    # Add VS Code repository
    subheader "Adding VS Code repository"
    if [[ ! -f /etc/apt/sources.list.d/vscode.list ]]; then
        echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | \
            sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
        sudo apt-get update >> "$LOG_FILE" 2>&1
    fi

    # Install VS Code
    subheader "Installing VS Code"
    ensure_package code

    success "VS Code installed"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/../helpers/all.sh"
    install_editors
fi
