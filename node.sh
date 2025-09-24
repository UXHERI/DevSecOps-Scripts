#!/bin/bash

<< task
Install Node.js using NVM and verify versions.
task

# Colors
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

echo -e "${YELLOW}${BOLD}Downloading and installing NVM...${RESET}"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

# Load NVM into the current shell
echo -e "${YELLOW}${BOLD}Loading NVM into current session...${RESET}"
export NVM_DIR="$HOME/.nvm"
# shellcheck source=/dev/null
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Confirm NVM loaded
if command -v nvm &> /dev/null; then
    echo -e "${GREEN}${BOLD}✔ NVM installed and loaded successfully.${RESET}"
else
    echo -e "${RED}${BOLD}❌ Failed to load NVM. Please restart your shell manually and try again.${RESET}"
    exit 1
fi

echo -e "${YELLOW}${BOLD}Installing Node.js v22...${RESET}"
nvm install 22

echo -e "${YELLOW}${BOLD}Verifying Node.js and npm versions...${RESET}"
NODE_VERSION=$(node -v)
NPM_VERSION=$(npm -v)

if [[ "$NODE_VERSION" == v22* ]]; then
    echo -e "${GREEN}${BOLD}✔ Node.js version: $NODE_VERSION${RESET}"
else
    echo -e "${RED}${BOLD}❌ Node.js was not installed correctly.${RESET}"
    exit 1
fi

echo -e "${GREEN}${BOLD}✔ npm version: $NPM_VERSION${RESET}"
