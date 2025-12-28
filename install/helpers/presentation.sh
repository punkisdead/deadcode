#!/bin/bash
# Deadcode - Presentation Helper Functions
# Provides whiptail-based TUI menus and dialogs

# Terminal dimensions
calc_dimensions() {
    TERM_HEIGHT=$(tput lines 2>/dev/null || echo 24)
    TERM_WIDTH=$(tput cols 2>/dev/null || echo 80)

    # Dialog dimensions (leave some margin)
    DIALOG_HEIGHT=$((TERM_HEIGHT - 4))
    DIALOG_WIDTH=$((TERM_WIDTH - 10))

    # Constrain to reasonable sizes
    [[ $DIALOG_HEIGHT -gt 30 ]] && DIALOG_HEIGHT=30 || true
    [[ $DIALOG_WIDTH -gt 80 ]] && DIALOG_WIDTH=80 || true
    [[ $DIALOG_HEIGHT -lt 15 ]] && DIALOG_HEIGHT=15 || true
    [[ $DIALOG_WIDTH -lt 50 ]] && DIALOG_WIDTH=50 || true

    # List height for menus
    LIST_HEIGHT=$((DIALOG_HEIGHT - 8))
    [[ $LIST_HEIGHT -lt 5 ]] && LIST_HEIGHT=5 || true
}

# Initialize dimensions
calc_dimensions

# Show a menu and return the selected option
# Usage: show_menu "Title" "Message" "tag1" "description1" "tag2" "description2" ...
# Returns: selected tag via stdout
show_menu() {
    local title="$1"
    local text="$2"
    shift 2

    calc_dimensions
    whiptail --title "$title" \
             --menu "$text" \
             "$DIALOG_HEIGHT" "$DIALOG_WIDTH" "$LIST_HEIGHT" \
             "$@" \
             3>&1 1>&2 2>&3
}

# Show a checklist and return selected options
# Usage: show_checklist "Title" "Message" "tag1" "description1" "ON/OFF" "tag2" "description2" "ON/OFF" ...
# Returns: space-separated list of selected tags via stdout
show_checklist() {
    local title="$1"
    local text="$2"
    shift 2

    calc_dimensions
    whiptail --title "$title" \
             --checklist "$text" \
             "$DIALOG_HEIGHT" "$DIALOG_WIDTH" "$LIST_HEIGHT" \
             "$@" \
             3>&1 1>&2 2>&3
}

# Show a radiolist and return selected option
# Usage: show_radiolist "Title" "Message" "tag1" "description1" "ON/OFF" ...
# Returns: selected tag via stdout
show_radiolist() {
    local title="$1"
    local text="$2"
    shift 2

    calc_dimensions
    whiptail --title "$title" \
             --radiolist "$text" \
             "$DIALOG_HEIGHT" "$DIALOG_WIDTH" "$LIST_HEIGHT" \
             "$@" \
             3>&1 1>&2 2>&3
}

# Show a yes/no confirmation dialog
# Usage: confirm "Question text" ["Title"]
# Returns: 0 for yes, 1 for no
confirm() {
    local text="$1"
    local title="${2:-Confirm}"

    calc_dimensions
    whiptail --title "$title" \
             --yesno "$text" \
             10 "$DIALOG_WIDTH"
}

# Show an input box and return the entered text
# Usage: show_input "Title" "Message" ["default value"]
# Returns: entered text via stdout
show_input() {
    local title="$1"
    local text="$2"
    local default="${3:-}"

    calc_dimensions
    whiptail --title "$title" \
             --inputbox "$text" \
             10 "$DIALOG_WIDTH" \
             "$default" \
             3>&1 1>&2 2>&3
}

# Show a password input box
# Usage: show_password "Title" "Message"
# Returns: entered password via stdout
show_password() {
    local title="$1"
    local text="$2"

    calc_dimensions
    whiptail --title "$title" \
             --passwordbox "$text" \
             10 "$DIALOG_WIDTH" \
             3>&1 1>&2 2>&3
}

# Show a message box (OK button)
# Usage: show_message "Title" "Message"
show_message() {
    local title="$1"
    local text="$2"

    calc_dimensions
    whiptail --title "$title" \
             --msgbox "$text" \
             "$DIALOG_HEIGHT" "$DIALOG_WIDTH"
}

# Show an info box (no button, disappears)
# Usage: show_info "Title" "Message"
show_info() {
    local title="$1"
    local text="$2"

    calc_dimensions
    whiptail --title "$title" \
             --infobox "$text" \
             10 "$DIALOG_WIDTH"
}

# Show a progress gauge
# Usage: echo "50" | show_gauge "Title" "Message"
# Or: show_gauge_cmd "Title" "Message" command [args...]
show_gauge() {
    local title="$1"
    local text="$2"

    calc_dimensions
    whiptail --title "$title" \
             --gauge "$text" \
             8 "$DIALOG_WIDTH" 0
}

# Run a command and show progress
# Usage: show_gauge_cmd "Title" "Message" command [args...]
show_gauge_cmd() {
    local title="$1"
    local text="$2"
    shift 2

    (
        # Run command in background
        "$@" &
        local pid=$!

        # Simulate progress
        local progress=0
        while ps -p $pid > /dev/null 2>&1; do
            echo $progress
            ((progress += 2))
            [[ $progress -gt 95 ]] && progress=95
            sleep 0.1
        done

        wait $pid
        local status=$?
        echo 100
        exit $status
    ) | show_gauge "$title" "$text"
}

# Show a text box (scrollable text display)
# Usage: show_textbox "Title" "/path/to/file"
show_textbox() {
    local title="$1"
    local file="$2"

    calc_dimensions
    whiptail --title "$title" \
             --textbox "$file" \
             "$DIALOG_HEIGHT" "$DIALOG_WIDTH" \
             --scrolltext
}

# Show welcome screen
show_welcome() {
    local version="${1:-1.0.0}"
    show_message "Welcome to Deadcode" "
    Deadcode - Debian Desktop Environment Configuration

    Version: $version

    This installer will help you set up a complete
    desktop environment with:

    - i3 window manager
    - Polybar status bar
    - Picom compositor
    - Rofi application launcher
    - Dunst notifications
    - Theme support (Nord, Catppuccin, Gruvbox, etc.)
    - And more!

    Press OK to continue."
}

# Show completion screen
show_complete() {
    show_message "Installation Complete" "
    Deadcode installation is complete!

    What's next:
    1. Log out and log back in
    2. Select 'i3' from the session menu
    3. Use deadcode-menu for configuration

    Useful commands:
    - deadcode-menu          : Main menu
    - deadcode-theme-set     : Change theme
    - deadcode-theme-list    : List themes
    - deadcode-update        : Update system

    Enjoy your new desktop environment!"
}

# Show an error dialog
show_error() {
    local title="Error"
    local text="$1"

    calc_dimensions
    whiptail --title "$title" \
             --msgbox "$text" \
             12 "$DIALOG_WIDTH"
}

# Clear the screen and show banner
clear_and_banner() {
    clear
    banner
}
