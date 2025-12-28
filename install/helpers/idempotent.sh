#!/bin/bash
# Deadcode - Idempotency Helper Functions
# Provides functions to ensure operations are idempotent (safe to run multiple times)

# Check if a package is installed
# Usage: is_installed "package-name"
is_installed() {
    local pkg="$1"
    dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"
}

# Ensure a package is installed (install only if missing)
# Usage: ensure_package "package-name"
ensure_package() {
    local pkg="$1"
    if is_installed "$pkg"; then
        debug "Package '$pkg' already installed, skipping"
        return 0
    fi

    subheader "Installing $pkg"
    if sudo apt-get install -y "$pkg" >> "$LOG_FILE" 2>&1; then
        success "Installed $pkg"
        return 0
    else
        error "Failed to install $pkg"
        return 1
    fi
}

# Install packages from a list file
# Usage: install_from_list "/path/to/packages.txt"
install_from_list() {
    local list_file="$1"
    local failed=0

    if [[ ! -f "$list_file" ]]; then
        error "Package list not found: $list_file"
        return 1
    fi

    while IFS= read -r pkg || [[ -n "$pkg" ]]; do
        # Skip empty lines and comments
        [[ -z "$pkg" || "$pkg" =~ ^[[:space:]]*# ]] && continue

        # Trim whitespace
        pkg=$(echo "$pkg" | xargs)

        if ! ensure_package "$pkg"; then
            ((failed++))
        fi
    done < "$list_file"

    return $failed
}

# Ensure a symlink exists and points to the correct target
# Usage: ensure_symlink "/path/to/target" "/path/to/link"
ensure_symlink() {
    local target="$1"
    local link="$2"

    # If link already exists and points to correct target, nothing to do
    if [[ -L "$link" ]]; then
        if [[ "$(readlink "$link")" == "$target" ]]; then
            debug "Symlink already correct: $link -> $target"
            return 0
        fi
        # Remove incorrect symlink
        rm "$link"
    elif [[ -e "$link" ]]; then
        # Backup existing file/directory
        warn "Backing up existing $link to ${link}.bak"
        mv "$link" "${link}.bak"
    fi

    # Create parent directory if needed
    mkdir -p "$(dirname "$link")"

    # Create symlink
    if ln -snf "$target" "$link"; then
        debug "Created symlink: $link -> $target"
        return 0
    else
        error "Failed to create symlink: $link -> $target"
        return 1
    fi
}

# Check if a systemd service is enabled
# Usage: is_service_enabled "service-name"
is_service_enabled() {
    local service="$1"
    systemctl is-enabled "$service" 2>/dev/null | grep -q "enabled"
}

# Check if a systemd service is active (running)
# Usage: is_service_active "service-name"
is_service_active() {
    local service="$1"
    systemctl is-active "$service" 2>/dev/null | grep -q "active"
}

# Ensure a systemd service is enabled (and optionally started)
# Usage: ensure_service "service-name" [start]
ensure_service() {
    local service="$1"
    local start="${2:-false}"

    if ! is_service_enabled "$service"; then
        subheader "Enabling $service"
        if sudo systemctl enable "$service" >> "$LOG_FILE" 2>&1; then
            success "Enabled $service"
        else
            error "Failed to enable $service"
            return 1
        fi
    else
        debug "Service $service already enabled"
    fi

    if [[ "$start" == "start" ]] && ! is_service_active "$service"; then
        subheader "Starting $service"
        if sudo systemctl start "$service" >> "$LOG_FILE" 2>&1; then
            success "Started $service"
        else
            error "Failed to start $service"
            return 1
        fi
    fi

    return 0
}

# Ensure a directory exists
# Usage: ensure_dir "/path/to/directory" [mode] [owner]
ensure_dir() {
    local dir="$1"
    local mode="${2:-}"
    local owner="${3:-}"

    if [[ -d "$dir" ]]; then
        debug "Directory already exists: $dir"
    else
        if mkdir -p "$dir"; then
            debug "Created directory: $dir"
        else
            error "Failed to create directory: $dir"
            return 1
        fi
    fi

    # Set mode if specified
    if [[ -n "$mode" ]]; then
        chmod "$mode" "$dir"
    fi

    # Set owner if specified
    if [[ -n "$owner" ]]; then
        chown "$owner" "$dir"
    fi

    return 0
}

# Ensure a file exists with specific content
# Usage: ensure_file "/path/to/file" "content" [mode]
ensure_file() {
    local file="$1"
    local content="$2"
    local mode="${3:-644}"

    # Create parent directory if needed
    ensure_dir "$(dirname "$file")"

    # Check if file already has correct content
    if [[ -f "$file" ]]; then
        local existing
        existing=$(cat "$file")
        if [[ "$existing" == "$content" ]]; then
            debug "File already has correct content: $file"
            return 0
        fi
        # Backup existing file
        cp "$file" "${file}.bak"
    fi

    # Write content
    if echo "$content" > "$file"; then
        chmod "$mode" "$file"
        debug "Created/updated file: $file"
        return 0
    else
        error "Failed to write file: $file"
        return 1
    fi
}

# Check if a migration has been run
# Usage: migration_done "migration-name"
migration_done() {
    local migration="$1"
    local state_dir="${HOME}/.local/state/deadcode/migrations"
    [[ -f "$state_dir/$migration" ]]
}

# Mark a migration as complete
# Usage: mark_migration_done "migration-name"
mark_migration_done() {
    local migration="$1"
    local state_dir="${HOME}/.local/state/deadcode/migrations"
    ensure_dir "$state_dir"
    touch "$state_dir/$migration"
}

# Run a command only if not already done (based on marker file)
# Usage: run_once "marker-name" "command" [args...]
run_once() {
    local marker="$1"
    shift

    if migration_done "$marker"; then
        debug "Already done: $marker"
        return 0
    fi

    if "$@"; then
        mark_migration_done "$marker"
        return 0
    else
        return 1
    fi
}

# Check if running as root
is_root() {
    [[ $EUID -eq 0 ]]
}

# Require root privileges
require_root() {
    if ! is_root; then
        fatal "This script must be run as root (use sudo)"
    fi
}

# Check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Require a command to exist
require_command() {
    local cmd="$1"
    if ! command_exists "$cmd"; then
        fatal "Required command not found: $cmd"
    fi
}
