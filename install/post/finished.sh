#!/bin/bash
# Deadcode - Installation Complete Message
# Shows final instructions and summary

show_finished() {
    header "Installation Complete"

    echo ""
    echo "Deadcode has been successfully installed!"
    echo ""
    echo "Next steps:"
    echo "  1. Log out or reboot"
    echo "  2. Select 'i3' from the session menu at the login screen"
    echo "  3. Log in and enjoy your new desktop"
    echo ""
    echo "Useful commands:"
    echo "  deadcode-menu          - Main configuration menu"
    echo "  deadcode-theme-set     - Change color theme"
    echo "  deadcode-theme-list    - List available themes"
    echo "  deadcode-update        - Update system"
    echo ""
    echo "Default keybindings:"
    echo "  Mod+Enter              - Open terminal"
    echo "  Mod+d                  - Open rofi launcher"
    echo "  Mod+Shift+q            - Close window"
    echo "  Mod+Shift+e            - Exit i3"
    echo ""
    success "Happy computing!"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/../helpers/all.sh"
    show_finished
fi
