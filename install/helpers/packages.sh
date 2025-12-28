#!/bin/bash
# Deadcode - Package Helper Functions
# Provides apt package management utilities

# Update package lists
update_package_lists() {
    header "Updating package lists"
    if sudo apt-get update >> "$LOG_FILE" 2>&1; then
        success "Package lists updated"
        return 0
    else
        error "Failed to update package lists"
        return 1
    fi
}

# Upgrade installed packages
upgrade_packages() {
    header "Upgrading installed packages"
    if sudo apt-get upgrade -y >> "$LOG_FILE" 2>&1; then
        success "Packages upgraded"
        return 0
    else
        error "Failed to upgrade packages"
        return 1
    fi
}

# Full system upgrade (dist-upgrade)
full_upgrade() {
    header "Performing full system upgrade"
    if sudo apt-get dist-upgrade -y >> "$LOG_FILE" 2>&1; then
        success "Full upgrade complete"
        return 0
    else
        error "Failed to perform full upgrade"
        return 1
    fi
}

# Install a list of packages
# Usage: install_packages pkg1 pkg2 pkg3 ...
install_packages() {
    local packages=("$@")
    local failed=0

    for pkg in "${packages[@]}"; do
        if ! ensure_package "$pkg"; then
            ((failed++))
        fi
    done

    return $failed
}

# Remove a package
# Usage: remove_package "package-name"
remove_package() {
    local pkg="$1"

    if ! is_installed "$pkg"; then
        debug "Package '$pkg' not installed, nothing to remove"
        return 0
    fi

    subheader "Removing $pkg"
    if sudo apt-get remove -y "$pkg" >> "$LOG_FILE" 2>&1; then
        success "Removed $pkg"
        return 0
    else
        error "Failed to remove $pkg"
        return 1
    fi
}

# Purge a package (remove config files too)
# Usage: purge_package "package-name"
purge_package() {
    local pkg="$1"

    subheader "Purging $pkg"
    if sudo apt-get purge -y "$pkg" >> "$LOG_FILE" 2>&1; then
        success "Purged $pkg"
        return 0
    else
        error "Failed to purge $pkg"
        return 1
    fi
}

# Clean up unused packages
cleanup_packages() {
    header "Cleaning up unused packages"

    subheader "Running autoremove"
    sudo apt-get autoremove -y >> "$LOG_FILE" 2>&1

    subheader "Running autoclean"
    sudo apt-get autoclean >> "$LOG_FILE" 2>&1

    success "Cleanup complete"
}

# Install packages from a category file
# Usage: install_category "core" (reads from packages/core.txt)
install_category() {
    local category="$1"
    local list_file="${DEADCODE_PATH}/packages/${category}.txt"

    header "Installing $category packages"

    if [[ ! -f "$list_file" ]]; then
        error "Package list not found: $list_file"
        return 1
    fi

    install_from_list "$list_file"
}

# Check if apt is locked
is_apt_locked() {
    if sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; then
        return 0
    fi
    return 1
}

# Wait for apt lock to be released
wait_for_apt() {
    local max_wait=60
    local waited=0

    while is_apt_locked; do
        if [[ $waited -eq 0 ]]; then
            warn "Waiting for apt lock to be released..."
        fi
        sleep 1
        ((waited++))
        if [[ $waited -ge $max_wait ]]; then
            error "Timed out waiting for apt lock"
            return 1
        fi
    done

    return 0
}

# Add a PPA or external repository
# Usage: add_repository "ppa:user/repo" or "deb http://..."
add_repository() {
    local repo="$1"

    if ! command_exists add-apt-repository; then
        ensure_package software-properties-common
    fi

    subheader "Adding repository: $repo"
    if sudo add-apt-repository -y "$repo" >> "$LOG_FILE" 2>&1; then
        success "Added repository: $repo"
        update_package_lists
        return 0
    else
        error "Failed to add repository: $repo"
        return 1
    fi
}

# Install a .deb file
# Usage: install_deb "/path/to/package.deb"
install_deb() {
    local deb_file="$1"

    if [[ ! -f "$deb_file" ]]; then
        error "Deb file not found: $deb_file"
        return 1
    fi

    subheader "Installing $(basename "$deb_file")"
    if sudo dpkg -i "$deb_file" >> "$LOG_FILE" 2>&1; then
        success "Installed $(basename "$deb_file")"
        return 0
    else
        warn "Fixing dependencies..."
        sudo apt-get install -f -y >> "$LOG_FILE" 2>&1
        return $?
    fi
}

# Download and install a .deb from URL
# Usage: install_deb_url "https://example.com/package.deb"
install_deb_url() {
    local url="$1"
    local filename=$(basename "$url")
    local tmp_file="/tmp/$filename"

    subheader "Downloading $filename"
    if wget -q -O "$tmp_file" "$url"; then
        install_deb "$tmp_file"
        rm -f "$tmp_file"
        return $?
    else
        error "Failed to download: $url"
        return 1
    fi
}

# Get installed package version
# Usage: get_package_version "package-name"
get_package_version() {
    local pkg="$1"
    dpkg-query -W -f='${Version}' "$pkg" 2>/dev/null
}

# Check if package needs upgrade
# Usage: needs_upgrade "package-name"
needs_upgrade() {
    local pkg="$1"
    apt list --upgradable 2>/dev/null | grep -q "^$pkg/"
}
