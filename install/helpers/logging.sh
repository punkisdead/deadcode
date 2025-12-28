#!/bin/bash
# Deadcode - Logging Helper Functions
# Provides colored output and logging functionality

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[0;37m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color

# Log file location
LOG_FILE="${LOG_FILE:-/tmp/deadcode-install.log}"

# Initialize log file
init_log() {
    echo "=== Deadcode Installation Log ===" > "$LOG_FILE"
    echo "Started: $(date)" >> "$LOG_FILE"
    echo "=================================" >> "$LOG_FILE"
}

# Log to file
log_to_file() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

# Info message (blue)
info() {
    echo -e "${BLUE}[INFO]${NC} $*"
    log_to_file "INFO: $*"
}

# Success message (green)
success() {
    echo -e "${GREEN}[OK]${NC} $*"
    log_to_file "SUCCESS: $*"
}

# Warning message (yellow)
warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
    log_to_file "WARNING: $*"
}

# Error message (red)
error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
    log_to_file "ERROR: $*"
}

# Fatal error - exits script
fatal() {
    echo -e "${RED}${BOLD}[FATAL]${NC} $*" >&2
    log_to_file "FATAL: $*"
    exit 1
}

# Header for sections (purple, bold)
header() {
    echo ""
    echo -e "${PURPLE}${BOLD}==> $*${NC}"
    echo ""
    log_to_file "=== $* ==="
}

# Sub-header for subsections (cyan)
subheader() {
    echo -e "${CYAN}  -> $*${NC}"
    log_to_file "  -> $*"
}

# Debug message (only shown if DEBUG=1)
debug() {
    if [[ "${DEBUG:-0}" == "1" ]]; then
        echo -e "${WHITE}[DEBUG]${NC} $*"
        log_to_file "DEBUG: $*"
    fi
}

# Print a horizontal line
hr() {
    echo -e "${BLUE}────────────────────────────────────────────────────────${NC}"
}

# Print the deadcode banner
banner() {
    echo -e "${PURPLE}${BOLD}"
    cat << 'EOF'
     _                 _                _
  __| | ___  __ _  __| | ___ ___   __| | ___
 / _` |/ _ \/ _` |/ _` |/ __/ _ \ / _` |/ _ \
| (_| |  __/ (_| | (_| | (_| (_) | (_| |  __/
 \__,_|\___|\__,_|\__,_|\___\___/ \__,_|\___|

EOF
    echo -e "${NC}"
    echo -e "${CYAN}  Debian Desktop Environment Configuration${NC}"
    echo ""
}

# Spinner for long-running operations
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while ps -p "$pid" > /dev/null 2>&1; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Run a command with spinner
run_with_spinner() {
    local msg="$1"
    shift
    printf "${BLUE}[...]${NC} %s" "$msg"
    "$@" >> "$LOG_FILE" 2>&1 &
    local pid=$!
    spinner $pid
    wait $pid
    local status=$?
    if [[ $status -eq 0 ]]; then
        printf "\r${GREEN}[OK]${NC}  %s\n" "$msg"
    else
        printf "\r${RED}[FAIL]${NC} %s\n" "$msg"
    fi
    return $status
}
