#!/bin/bash
# Deadcode - Plymouth Boot Splash Configuration
# Installs and configures Plymouth with custom deadcode theme

PLYMOUTH_THEME_NAME="deadcode"
PLYMOUTH_THEME_DIR="/usr/share/plymouth/themes/${PLYMOUTH_THEME_NAME}"
SPLASH_SOURCE="${DEADCODE_PATH}/config/plymouth"

setup_plymouth() {
    header "Setting up Plymouth boot splash"

    # Install Plymouth
    install_from_list "${DEADCODE_PATH}/packages/plymouth.txt"

    # Install custom theme
    install_plymouth_theme

    # Set as default theme
    set_plymouth_theme

    # Configure GRUB for splash
    configure_grub_splash

    # Configure initramfs to include Plymouth
    configure_initramfs_plymouth

    # Update initramfs (must be last - includes Plymouth theme)
    update_initramfs

    success "Plymouth configured"
}

install_plymouth_theme() {
    subheader "Installing deadcode Plymouth theme"

    # Create theme directory
    sudo mkdir -p "$PLYMOUTH_THEME_DIR"

    # Copy splash images
    if [[ -f "${SPLASH_SOURCE}/splash-1080.png" ]]; then
        sudo cp "${SPLASH_SOURCE}/splash-1080.png" "${PLYMOUTH_THEME_DIR}/background.png"
    fi

    if [[ -f "${SPLASH_SOURCE}/splash-2k.png" ]]; then
        sudo cp "${SPLASH_SOURCE}/splash-2k.png" "${PLYMOUTH_THEME_DIR}/background-2k.png"
    fi

    if [[ -f "${SPLASH_SOURCE}/logo.svg" ]]; then
        sudo cp "${SPLASH_SOURCE}/logo.svg" "${PLYMOUTH_THEME_DIR}/logo.svg"
    fi

    # Create theme definition file
    sudo tee "${PLYMOUTH_THEME_DIR}/${PLYMOUTH_THEME_NAME}.plymouth" > /dev/null << EOF
[Plymouth Theme]
Name=Deadcode
Description=Deadcode boot splash for Debian
ModuleName=script

[script]
ImageDir=${PLYMOUTH_THEME_DIR}
ScriptFile=${PLYMOUTH_THEME_DIR}/${PLYMOUTH_THEME_NAME}.script
EOF

    # Create Plymouth script with proper initialization order
    sudo tee "${PLYMOUTH_THEME_DIR}/${PLYMOUTH_THEME_NAME}.script" > /dev/null << 'SCRIPT'
# Deadcode Plymouth Theme Script
# Proper initialization order is critical for cryptsetup integration

# Window setup - must be first
Window.SetBackgroundTopColor(0.06, 0.06, 0.06);
Window.SetBackgroundBottomColor(0.06, 0.06, 0.06);

# Get window dimensions
screen_width = Window.GetWidth();
screen_height = Window.GetHeight();

# Background image (optional - works without it)
bg_image = Image("background.png");
if (bg_image) {
    scaled_bg = bg_image.Scale(screen_width, screen_height);
    bg_sprite = Sprite(scaled_bg);
    bg_sprite.SetX(0);
    bg_sprite.SetY(0);
    bg_sprite.SetZ(-100);
}

# Pre-initialize all sprites before callbacks are registered
prompt_sprite = Sprite();
bullet_sprite = Sprite();
message_sprite = Sprite();

# Password dialog callback - called when LUKS password is needed
fun display_password_callback(prompt_text, bullet_count) {
    # Replace default cryptsetup prompt with custom text
    prompt_text = "Enter disk passphrase:";

    # Render the prompt text
    prompt_image = Image.Text(prompt_text, 0.88, 0.88, 0.88, 1, "Sans 14");
    prompt_sprite.SetImage(prompt_image);
    prompt_sprite.SetX(screen_width / 2 - prompt_image.GetWidth() / 2);
    prompt_sprite.SetY(screen_height / 2);
    prompt_sprite.SetZ(10);

    # Build bullet string for password feedback
    bullet_str = "";
    for (i = 0; i < bullet_count; i++) {
        bullet_str = bullet_str + "*";
    }

    # Only render bullets if there are any
    if (bullet_count > 0) {
        bullet_image = Image.Text(bullet_str, 0.39, 0.40, 0.95, 1, "Sans 16");
        bullet_sprite.SetImage(bullet_image);
        bullet_sprite.SetX(screen_width / 2 - bullet_image.GetWidth() / 2);
        bullet_sprite.SetY(screen_height / 2 + 40);
        bullet_sprite.SetZ(10);
    } else {
        # Clear bullets when empty
        bullet_sprite.SetImage(Image.Text("", 1, 1, 1));
    }
}

# Normal password callback (non-LUKS prompts)
fun display_normal_callback(prompt_text) {
    prompt_image = Image.Text(prompt_text, 0.88, 0.88, 0.88, 1, "Sans 14");
    prompt_sprite.SetImage(prompt_image);
    prompt_sprite.SetX(screen_width / 2 - prompt_image.GetWidth() / 2);
    prompt_sprite.SetY(screen_height / 2);
    prompt_sprite.SetZ(10);
}

# Message callback
fun message_callback(msg) {
    # Suppress #NULL and empty messages from cryptsetup
    if (msg == "#NULL" || msg == "" || msg == NULL) {
        message_sprite.SetImage(Image.Text("", 0, 0, 0, 0));
        return;
    }

    msg_image = Image.Text(msg, 1, 1, 1, 1, "Sans 12");
    message_sprite.SetImage(msg_image);
    message_sprite.SetX(screen_width / 2 - msg_image.GetWidth() / 2);
    message_sprite.SetY(screen_height * 0.75);
    message_sprite.SetZ(10);
}

# Register callbacks - must happen after sprite initialization
Plymouth.SetDisplayPasswordFunction(display_password_callback);
Plymouth.SetDisplayNormalFunction(display_normal_callback);
Plymouth.SetMessageFunction(message_callback);
SCRIPT

    # Register theme with alternatives system (required for Debian)
    sudo update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth \
        "${PLYMOUTH_THEME_DIR}/${PLYMOUTH_THEME_NAME}.plymouth" 100

    success "Plymouth theme installed"
}

configure_initramfs_plymouth() {
    local initramfs_conf="/etc/initramfs-tools/conf.d/plymouth"

    subheader "Configuring initramfs for Plymouth"

    # Create Plymouth initramfs config with LUKS support
    sudo tee "$initramfs_conf" > /dev/null << 'EOF'
FRAMEBUFFER=y
EOF

    # Ensure cryptsetup is included in initramfs for LUKS support
    local cryptsetup_conf="/etc/initramfs-tools/conf.d/cryptsetup"
    if [[ -e /dev/mapper/*_crypt ]] || grep -q "_crypt" /etc/crypttab 2>/dev/null; then
        sudo tee "$cryptsetup_conf" > /dev/null << 'EOF'
CRYPTSETUP=y
EOF
        debug "LUKS detected, enabled cryptsetup in initramfs"
    fi

    success "Initramfs Plymouth config created"
}

set_plymouth_theme() {
    local current_theme
    current_theme=$(plymouth-set-default-theme 2>/dev/null || echo "")

    if [[ "$current_theme" == "$PLYMOUTH_THEME_NAME" ]]; then
        debug "Plymouth theme already set"
        return 0
    fi

    subheader "Setting Plymouth theme"
    sudo plymouth-set-default-theme "$PLYMOUTH_THEME_NAME"
    success "Plymouth theme set to: $PLYMOUTH_THEME_NAME"
}

configure_grub_splash() {
    local grub_config="/etc/default/grub"

    if ! grep -q "splash" "$grub_config" 2>/dev/null; then
        subheader "Configuring GRUB for splash"

        # Backup
        sudo cp "$grub_config" "${grub_config}.bak"

        # Add splash to GRUB_CMDLINE_LINUX_DEFAULT
        if grep -q 'GRUB_CMDLINE_LINUX_DEFAULT=' "$grub_config"; then
            # Append splash if not present
            sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\([^"]*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 quiet splash"/' "$grub_config"
            # Clean up any double quiet or splash
            sudo sed -i 's/quiet quiet/quiet/g; s/splash splash/splash/g' "$grub_config"
        else
            echo 'GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"' | sudo tee -a "$grub_config" > /dev/null
        fi

        # Update GRUB
        sudo update-grub
        success "GRUB configured for splash"
    else
        debug "GRUB splash already configured"
    fi
}

update_initramfs() {
    subheader "Updating initramfs"
    sudo update-initramfs -u
    success "Initramfs updated"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/../helpers/all.sh"
    setup_plymouth
fi
