#!/bin/bash

<< task
Install NGINX on EC2 instance and open port 80 in its Security Group using AWS CLI.
task

# Colors
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

echo -e "${YELLOW}${BOLD}Updating package list...${RESET}"
sudo yum update -y

echo -e "${YELLOW}${BOLD}Installing NGINX...${RESET}"
sudo yum install nginx -y

echo -e "${YELLOW}${BOLD}Starting and enabling NGINX...${RESET}"
sudo systemctl start nginx
sudo systemctl enable nginx
sudo service nginx restart
sudo chkconfig nginx on

echo -e "${GREEN}${BOLD}✔ NGINX installed and running.${RESET}"
