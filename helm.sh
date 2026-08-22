#!/bin/bash

<< task
Install Helm on Ubuntu/Debian systems.
Includes repository setup, installation, and bash auto-completion.
task

# Colors
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

echo -e "${GREEN}${BOLD}********** HELM INSTALLATION STARTED **********${RESET}"

install_helm() {
  echo -e "${YELLOW}${BOLD}Installing dependencies...${RESET}"
  sudo apt-get install curl gpg apt-transport-https --yes

  echo -e "${YELLOW}${BOLD}Adding Helm GPG key...${RESET}"
  curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey | \
    gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null

  echo -e "${YELLOW}${BOLD}Adding Helm repository...${RESET}"
  echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" | \
    sudo tee /etc/apt/sources.list.d/helm-stable-debian.list

  echo -e "${YELLOW}${BOLD}Updating package list and installing Helm...${RESET}"
  sudo apt-get update
  sudo apt-get install helm -y

  echo -e "${YELLOW}${BOLD}Setting up Helm auto-completion...${RESET}"
  echo 'source <(helm completion bash)' >> ~/.bashrc
  echo 'alias h=helm' >> ~/.bashrc
  echo 'complete -F __start_helm h' >> ~/.bashrc

  # Apply changes immediately
  source ~/.bashrc
}

if ! install_helm; then
  echo -e "${RED}${BOLD}❌ Helm installation failed.${RESET}"
  exit 1
else
  echo -e "${GREEN}${BOLD}✅ Helm installed successfully!${RESET}"
  helm version
fi
