#!/bin/bash

<< task
Install Terraform CLI from official HashiCorp APT repository.
Used for Infrastructure as Code (IaC).
task

# Colors
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
RED='\033[1;31m'
BOLD='\033[1m'
RESET='\033[0m'

install_terraform() {
    echo -e "${YELLOW}${BOLD}Installing Terraform...${RESET}"
    
    # Add HashiCorp GPG key
    wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    
    # Add repository to sources list
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

    # Update and install
    sudo apt update && sudo apt install -y terraform

    if terraform -v > /dev/null 2>&1; then
        echo -e "${GREEN}${BOLD}✔ Terraform installed successfully!${RESET}"
        terraform -v
    else
        echo -e "${RED}${BOLD}❌ Terraform installation failed.${RESET}"
        exit 1
    fi
}

echo -e "${YELLOW}${BOLD}********** TERRAFORM INSTALLATION STARTED **********${RESET}"

install_terraform

echo -e "${GREEN}${BOLD}********** TERRAFORM INSTALLATION COMPLETE **********${RESET}"
