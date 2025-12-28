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

    # Update initramfs
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

    # Create Plymouth script
    sudo tee "${PLYMOUTH_THEME_DIR}/${PLYMOUTH_THEME_NAME}.script" > /dev/null << 'SCRIPT'
# Deadcode Plymouth Theme Script

# Colors matching the deadcode theme
bg_color = 0x0f0f0f;
text_color = 0xe0e0e0;
accent_color = 0x6366f1;

# Window dimensions
window.width = Window.GetWidth();
window.height = Window.GetHeight();

# Background
background_image = Image("background.png");
background_image = background_image.Scale(window.width, window.height);
background_sprite = Sprite(background_image);
background_sprite.SetPosition(0, 0, -100);

# Password prompt styling
fun dialog_setup() {
    local.dialog_image = Image("dialog.png");
    local.dialog_sprite = Sprite(local.dialog_image);
    local.dialog_sprite.SetPosition(
        (window.width - local.dialog_image.GetWidth()) / 2,
        (window.height - local.dialog_image.GetHeight()) / 2,
        10
    );
}

# Message display
message_sprite = Sprite();
message_sprite.SetPosition(window.width / 2, window.height * 0.75, 10);

fun message_callback(text) {
    message_image = Image.Text(text, 1, 1, 1);
    message_sprite.SetImage(message_image);
    message_sprite.SetPosition(
        (window.width - message_image.GetWidth()) / 2,
        window.height * 0.75,
        10
    );
}

# Password prompt
fun display_password_callback(prompt, bullets) {
    password_dialog.image = Image.Text(prompt, 0.88, 0.88, 0.88);
    password_dialog.sprite.SetImage(password_dialog.image);
    password_dialog.sprite.SetPosition(
        (window.width - password_dialog.image.GetWidth()) / 2,
        window.height / 2 + 50,
        10
    );

    # Display bullets for password
    bullet_string = "";
    for (i = 0; i < bullets; i++) {
        bullet_string += "●";
    }

    bullet_image = Image.Text(bullet_string, 0.39, 0.4, 0.95);
    password_bullet.sprite.SetImage(bullet_image);
    password_bullet.sprite.SetPosition(
        (window.width - bullet_image.GetWidth()) / 2,
        window.height / 2 + 80,
        10
    );
}

# Initialize sprites
password_dialog.sprite = Sprite();
password_bullet.sprite = Sprite();

Plymouth.SetDisplayPasswordFunction(display_password_callback);
Plymouth.SetMessageFunction(message_callback);
SCRIPT

    success "Plymouth theme installed"
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
