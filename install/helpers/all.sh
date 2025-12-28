#!/bin/bash
# Deadcode - Helper Loader
# Sources all helper scripts

# Get the directory of this script
HELPERS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source all helper scripts in order (logging first, as others depend on it)
source "${HELPERS_DIR}/logging.sh"
source "${HELPERS_DIR}/idempotent.sh"
source "${HELPERS_DIR}/packages.sh"
source "${HELPERS_DIR}/presentation.sh"

# Initialize logging
init_log

# Export common paths
export DEADCODE_PATH="${DEADCODE_PATH:-$(cd "${HELPERS_DIR}/../.." && pwd)}"
export DEADCODE_CONFIG="${HOME}/.config/deadcode"
export DEADCODE_DATA="${HOME}/.local/share/deadcode"
export DEADCODE_STATE="${HOME}/.local/state/deadcode"

# Ensure state directories exist
ensure_dir "$DEADCODE_CONFIG"
ensure_dir "$DEADCODE_DATA"
ensure_dir "$DEADCODE_STATE"
ensure_dir "$DEADCODE_STATE/migrations"

debug "Helpers loaded from: $HELPERS_DIR"
debug "Deadcode path: $DEADCODE_PATH"
