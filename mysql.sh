#!/bin/bash

<< task
Install MySQL Client 8.0 on Amazon Linux 2023 or RHEL9-based EC2 instances.
task

# Colors
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

echo -e "${YELLOW}${BOLD}Downloading MySQL 8.0 community repo RPM...${RESET}"
wget https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm

echo -e "${YELLOW}${BOLD}Installing MySQL repository...${RESET}"
sudo dnf install mysql80-community-release-el9-1.noarch.rpm -y

echo -e "${YELLOW}${BOLD}Importing GPG key...${RESET}"
sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2023

echo -e "${YELLOW}${BOLD}Installing MySQL Client...${RESET}"
sudo dnf install mysql-community-client -y

# Verify installation
echo -e "${YELLOW}${BOLD}Verifying MySQL Client installation...${RESET}"
MYSQL_VERSION=$(mysql --version)

if [[ "$MYSQL_VERSION" == *"mysql"* ]]; then
    echo -e "${GREEN}${BOLD}✔ MySQL Client installed successfully:${RESET} $MYSQL_VERSION"
else
    echo -e "${RED}${BOLD}❌ MySQL installation failed or not found.${RESET}"
    exit 1
fi
