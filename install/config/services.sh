#!/bin/bash
# Deadcode - System Services Configuration
# Enables required systemd services

# Services to enable
SERVICES=(
    "acpid"
    "NetworkManager"
)

# Optional services (enabled if packages are installed)
OPTIONAL_SERVICES=(
    "bluetooth:bluez"
    "cups:cups"
)

setup_services() {
    header "Configuring system services"

    # Enable required services
    for service in "${SERVICES[@]}"; do
        enable_service "$service"
    done

    # Enable optional services if packages installed
    for entry in "${OPTIONAL_SERVICES[@]}"; do
        local service="${entry%%:*}"
        local package="${entry##*:}"

        if is_installed "$package"; then
            enable_service "$service"
        else
            debug "Skipping $service (package $package not installed)"
        fi
    done

    success "Services configured"
}

enable_service() {
    local service="$1"

    if ! systemctl list-unit-files "${service}.service" &>/dev/null; then
        debug "Service not found: $service"
        return 0
    fi

    if is_service_enabled "$service"; then
        debug "Service already enabled: $service"
    else
        subheader "Enabling $service"
        sudo systemctl enable "$service"
        success "Enabled $service"
    fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/../helpers/all.sh"
    setup_services
fi
