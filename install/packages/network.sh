#!/bin/bash
# Deadcode - Network Installation
# Installs NetworkManager and configures WiFi power saving

install_network() {
    header "Installing network management"
    install_from_list "${DEADCODE_PATH}/packages/network.txt"

    # Enable NetworkManager service
    ensure_service "NetworkManager"

    # Disable WiFi power saving for better performance
    disable_wifi_powersave
}

disable_wifi_powersave() {
    local config_file="/etc/NetworkManager/conf.d/wifi-powersave-off.conf"

    if [[ -f "$config_file" ]]; then
        debug "WiFi power saving already configured"
        return 0
    fi

    subheader "Disabling WiFi power saving"

    sudo tee "$config_file" > /dev/null << 'EOF'
[connection]
# Disable WiFi power saving for better performance
# Values: 0=default, 1=ignore, 2=disable, 3=enable
wifi.powersave = 2
EOF

    if [[ $? -eq 0 ]]; then
        success "WiFi power saving disabled"
        # Restart NetworkManager to apply
        sudo systemctl restart NetworkManager
    else
        error "Failed to configure WiFi power saving"
        return 1
    fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/../helpers/all.sh"
    install_network
fi
