#!/bin/bash

<< task
Install Kubernetes v1.34 tools: kubelet, kubeadm, and kubectl
Compatible with Ubuntu/Debian systems.
task

# Colors for output
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

echo -e "${GREEN}${BOLD}********** KUBERNETES v1.34 INSTALLATION STARTED **********${RESET}"

install_kubernetes() {
  echo -e "${YELLOW}${BOLD}Updating system packages...${RESET}"
  sudo apt-get update -y

  echo -e "${YELLOW}${BOLD}Installing prerequisites...${RESET}"
  sudo apt-get install -y apt-transport-https ca-certificates curl gpg

  echo -e "${YELLOW}${BOLD}Creating keyrings directory if missing...${RESET}"
  sudo mkdir -p -m 755 /etc/apt/keyrings

  echo -e "${YELLOW}${BOLD}Downloading Kubernetes GPG key...${RESET}"
  curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.34/deb/Release.key | \
    sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

  echo -e "${YELLOW}${BOLD}Adding Kubernetes APT repository...${RESET}"
  echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.34/deb/ /' | \
    sudo tee /etc/apt/sources.list.d/kubernetes.list

  echo -e "${YELLOW}${BOLD}Updating package index and installing Kubernetes tools...${RESET}"
  sudo apt-get update -y
  sudo apt-get install -y kubelet kubeadm kubectl

  echo -e "${YELLOW}${BOLD}Holding package versions to prevent unintended upgrades...${RESET}"
  sudo apt-mark hold kubelet kubeadm kubectl

  echo -e "${GREEN}${BOLD}✅ Kubernetes v1.34 installed successfully!${RESET}"
  echo -e "${GREEN}${BOLD}Versions:${RESET}"
  kubeadm version && kubectl version --client && kubelet --version
}

if ! install_kubernetes; then
  echo -e "${RED}${BOLD}❌ Kubernetes installation failed.${RESET}"
  exit 1
else
  echo -e "${GREEN}${BOLD}********** KUBERNETES INSTALLATION COMPLETED SUCCESSFULLY **********${RESET}"
fi
