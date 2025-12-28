#!/bin/bash
# Deadcode - LightDM Configuration
# Installs and configures LightDM display manager

setup_lightdm() {
    header "Setting up LightDM"

    # Check if a display manager is already active
    local current_dm
    current_dm=$(cat /etc/X11/default-display-manager 2>/dev/null | xargs basename 2>/dev/null || echo "")

    if [[ "$current_dm" == "lightdm" ]]; then
        success "LightDM already configured"
        return 0
    fi

    # Install LightDM
    install_from_list "${DEADCODE_PATH}/packages/lightdm.txt"

    # Configure LightDM GTK Greeter
    configure_greeter

    # Enable LightDM service
    subheader "Enabling LightDM"
    sudo systemctl enable lightdm

    # Set as default display manager
    if [[ -n "$current_dm" ]] && [[ "$current_dm" != "lightdm" ]]; then
        subheader "Setting LightDM as default display manager"
        echo "/usr/sbin/lightdm" | sudo tee /etc/X11/default-display-manager > /dev/null
    fi

    success "LightDM configured"
}

configure_greeter() {
    local config_file="/etc/lightdm/lightdm-gtk-greeter.conf"

    subheader "Configuring LightDM greeter"

    # Backup existing config
    if [[ -f "$config_file" ]]; then
        sudo cp "$config_file" "${config_file}.bak"
    fi

    # Write configuration
    sudo tee "$config_file" > /dev/null << 'EOF'
[greeter]
theme-name = Adwaita-dark
icon-theme-name = Adwaita
font-name = Sans 11
background = #1a1b26
user-background = false
position = 50%,center 50%,center
clock-format = %H:%M
indicators = ~host;~spacer;~clock;~spacer;~session;~power
EOF

    success "Greeter configured"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/../helpers/all.sh"
    setup_lightdm
fi
