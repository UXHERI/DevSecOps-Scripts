#!/bin/bash

<< task
Installing Amazon Q Developer CLI on Ubuntu EC2 instance
for DevOps and development workflows automation.
task

# Colors for better output
YELLOW="\033[1;33m"
GREEN="\033[1;32m"
RED="\033[1;31m"
RESET="\033[0m"
BOLD="\033[1m"

# Amazon Q download URL for Ubuntu/Debian
Q_DOWNLOAD_URL="https://desktop-release.q.us-east-1.amazonaws.com/latest/amazon-q.deb"
Q_PACKAGE="amazon-q.deb"

check_prerequisites() {
    echo -e "${YELLOW}${BOLD}Checking system prerequisites...${RESET}"
    
    # Check if running on Ubuntu
    if ! grep -q "Ubuntu" /etc/os-release; then
        echo -e "${RED}${BOLD}This script is designed for Ubuntu systems only!${RESET}"
        exit 1
    fi
    
    # Check if running as non-root user
    if [[ $EUID -eq 0 ]]; then
        echo -e "${RED}${BOLD}Please run this script as a non-root user with sudo privileges!${RESET}"
        exit 1
    fi
    
    echo -e "${GREEN}${BOLD}Prerequisites check complete.${RESET}"
}

update_system() {
    echo -e "${YELLOW}${BOLD}Updating system packages...${RESET}"
    sudo apt update && sudo apt upgrade -y
    echo -e "${GREEN}${BOLD}System update complete.${RESET}"
}

install_dependencies() {
    echo -e "${YELLOW}${BOLD}Installing required dependencies...${RESET}"
    sudo apt install -y \
        wget \
        curl \
        ca-certificates \
        gnupg \
        lsb-release
    echo -e "${GREEN}${BOLD}Dependencies installation complete.${RESET}"
}

download_amazon_q() {
    echo -e "${YELLOW}${BOLD}Downloading Amazon Q CLI package...${RESET}"
    
    # Remove existing package if present
    if [[ -f "$Q_PACKAGE" ]]; then
        rm -f "$Q_PACKAGE"
    fi
    
    # Download Amazon Q package
    if ! wget -O "$Q_PACKAGE" "$Q_DOWNLOAD_URL"; then
        echo -e "${RED}${BOLD}Failed to download Amazon Q package!${RESET}"
        exit 1
    fi
    
    echo -e "${GREEN}${BOLD}Amazon Q package download complete.${RESET}"
}

install_amazon_q() {
    echo -e "${YELLOW}${BOLD}Installing Amazon Q CLI...${RESET}"
    
    # Install the .deb package
    if ! sudo dpkg -i "$Q_PACKAGE"; then
        echo -e "${YELLOW}${BOLD}Fixing broken dependencies...${RESET}"
        sudo apt-get install -f -y
        
        # Retry installation
        if ! sudo dpkg -i "$Q_PACKAGE"; then
            echo -e "${RED}${BOLD}Amazon Q installation failed!${RESET}"
            exit 1
        fi
    fi
    
    echo -e "${GREEN}${BOLD}Amazon Q CLI installation complete.${RESET}"
}

configure_amazon_q() {
    echo -e "${YELLOW}${BOLD}Configuring Amazon Q CLI...${RESET}"
    
    # Add Q CLI to PATH if not already present
    if ! command -v q &> /dev/null; then
        echo 'export PATH="/opt/amazon/q/bin:$PATH"' >> ~/.bashrc
        export PATH="/opt/amazon/q/bin:$PATH"
    fi
    
    # Create AWS directory if it doesn't exist
    mkdir -p ~/.aws
    
    echo -e "${GREEN}${BOLD}Amazon Q CLI configuration complete.${RESET}"
}

verify_installation() {
    echo -e "${YELLOW}${BOLD}Verifying Amazon Q installation...${RESET}"
    
    # Source bashrc to get updated PATH
    source ~/.bashrc
    
    # Check if Q CLI is available
    if command -v q &> /dev/null; then
        echo -e "${GREEN}${BOLD}Amazon Q CLI version:${RESET}"
        q --version
        echo -e "${GREEN}${BOLD}Installation verification successful!${RESET}"
    else
        echo -e "${RED}${BOLD}Amazon Q CLI not found in PATH!${RESET}"
        echo -e "${YELLOW}Please restart your terminal or run: source ~/.bashrc${RESET}"
    fi
}

cleanup() {
    echo -e "${YELLOW}${BOLD}Cleaning up installation files...${RESET}"
    rm -f "$Q_PACKAGE"
    echo -e "${GREEN}${BOLD}Cleanup complete.${RESET}"
}

show_usage_info() {
    echo -e "${GREEN}${BOLD}********** AMAZON Q CLI INSTALLATION COMPLETE **********${RESET}"
    echo -e "${YELLOW}${BOLD}Next Steps:${RESET}"
    echo -e "1. Restart your terminal or run: ${BOLD}source ~/.bashrc${RESET}"
    echo -e "2. Login to Amazon Q: ${BOLD}q auth login${RESET}"
    echo -e "3. Start chatting: ${BOLD}q chat${RESET}"
    echo -e "4. Get help: ${BOLD}q --help${RESET}"
    echo ""
    echo -e "${YELLOW}${BOLD}Useful Commands:${RESET}"
    echo -e "• ${BOLD}q chat${RESET} - Start interactive chat session"
    echo -e "• ${BOLD}q auth status${RESET} - Check authentication status"
    echo -e "• ${BOLD}q settings${RESET} - Configure Q CLI settings"
    echo -e "• ${BOLD}q --version${RESET} - Show version information"
}

# Main execution flow
echo -e "${GREEN}${BOLD}********** AMAZON Q CLI INSTALLATION STARTED **********${RESET}"

if ! check_prerequisites; then
    echo -e "${RED}${BOLD}PREREQUISITES CHECK FAILED!!!${RESET}"
    exit 1
fi

if ! update_system; then
    echo -e "${RED}${BOLD}SYSTEM UPDATE FAILED!!!${RESET}"
    exit 1
fi

if ! install_dependencies; then
    echo -e "${RED}${BOLD}DEPENDENCIES INSTALLATION FAILED!!!${RESET}"
    exit 1
fi

if ! download_amazon_q; then
    echo -e "${RED}${BOLD}AMAZON Q DOWNLOAD FAILED!!!${RESET}"
    exit 1
fi

if ! install_amazon_q; then
    echo -e "${RED}${BOLD}AMAZON Q INSTALLATION FAILED!!!${RESET}"
    exit 1
fi

if ! configure_amazon_q; then
    echo -e "${RED}${BOLD}AMAZON Q CONFIGURATION FAILED!!!${RESET}"
    exit 1
fi

verify_installation
cleanup
show_usage_info

echo -e "${GREEN}${BOLD}********** AMAZON Q CLI INSTALLATION COMPLETED **********${RESET}"
