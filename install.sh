#!/bin/bash
# Deadcode - Remote Installation Script
# Usage: curl -fsSL https://raw.githubusercontent.com/punkisdead/deadcode/main/install.sh | bash
#
# This script:
# 1. Installs git if not present
# 2. Clones the deadcode repository
# 3. Runs the setup script

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Configuration
REPO_URL="${DEADCODE_REPO:-https://github.com/punkisdead/deadcode.git}"
INSTALL_DIR="${HOME}/.local/share/deadcode"

echo -e "${PURPLE}"
cat << 'EOF'
     _                 _                _
  __| | ___  __ _  __| | ___ ___   __| | ___
 / _` |/ _ \/ _` |/ _` |/ __/ _ \ / _` |/ _ \
| (_| |  __/ (_| | (_| | (_| (_) | (_| |  __/
 \__,_|\___|\__,_|\__,_|\___\___/ \__,_|\___|

EOF
echo -e "${NC}"
echo -e "${BLUE}Debian Desktop Environment Configuration${NC}"
echo ""

# Check for root
if [[ $EUID -eq 0 ]]; then
    echo -e "${RED}Error: Do not run this script as root.${NC}"
    echo "Run as your normal user - sudo will be used when needed."
    exit 1
fi

# Ensure sudo access
echo -e "${YELLOW}This script requires sudo access to install packages.${NC}"
if ! sudo -v; then
    echo -e "${RED}Error: Could not obtain sudo access.${NC}"
    exit 1
fi

# Install git if needed
if ! command -v git &> /dev/null; then
    echo -e "${BLUE}Installing git...${NC}"
    sudo apt-get update
    sudo apt-get install -y git
fi

# Clone or update repository
if [[ -d "$INSTALL_DIR" ]]; then
    echo -e "${BLUE}Updating existing installation...${NC}"
    cd "$INSTALL_DIR"
    git pull --autostash
else
    echo -e "${BLUE}Cloning deadcode repository...${NC}"
    mkdir -p "$(dirname "$INSTALL_DIR")"
    git clone "$REPO_URL" "$INSTALL_DIR"
fi

# Run setup
echo -e "${GREEN}Starting setup...${NC}"
cd "$INSTALL_DIR"
exec bash setup.sh
