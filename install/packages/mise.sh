#!/bin/bash
# Deadcode - Mise Version Manager Installation
# Installs mise (formerly rtx) - polyglot runtime manager

install_mise() {
    header "Installing mise"

    # Check if mise is already installed
    if command_exists mise; then
        debug "mise already installed"
        return 0
    fi

    subheader "Installing mise via official installer"
    if curl -fsSL https://mise.run | sh; then
        success "mise installed successfully"

        # Add mise activation to shell configs if not present
        setup_mise_shell
    else
        error "Failed to install mise"
        return 1
    fi
}

setup_mise_shell() {
    local bashrc="${HOME}/.bashrc"
    local zshrc="${HOME}/.zshrc"
    local mise_activation='eval "$(~/.local/bin/mise activate bash)"'
    local mise_activation_zsh='eval "$(~/.local/bin/mise activate zsh)"'

    # Add to .bashrc if not present
    if [[ -f "$bashrc" ]] && ! grep -q "mise activate" "$bashrc"; then
        subheader "Adding mise activation to .bashrc"
        echo "" >> "$bashrc"
        echo "# mise version manager" >> "$bashrc"
        echo "$mise_activation" >> "$bashrc"
    fi

    # Add to .zshrc if it exists and mise not present
    if [[ -f "$zshrc" ]] && ! grep -q "mise activate" "$zshrc"; then
        subheader "Adding mise activation to .zshrc"
        echo "" >> "$zshrc"
        echo "# mise version manager" >> "$zshrc"
        echo "$mise_activation_zsh" >> "$zshrc"
    fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/../helpers/all.sh"
    install_mise
fi
